import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cartie/core/api_services/call_helper.dart';
import 'package:cartie/core/utills/constant.dart' as constant;
import 'package:cartie/core/utills/notification_services.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class TrainingMapScreen extends StatefulWidget {
  @override
  _TrainingMapScreenState createState() => _TrainingMapScreenState();
}

class _TrainingMapScreenState extends State<TrainingMapScreen> {
  late GoogleMapController mapController;
  LatLng? currentLocation;
  Set<Polygon> polygons = {};
  bool isLoading = true;
  bool hasError = false;
  bool isInsideGeofence = true;
  StreamSubscription<Position>? positionStream;

  final Color primaryColor = Colors.red[900]!;
  final Color accentColor = Colors.redAccent;
  final Color backgroundColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    try {
      await _requestLocationPermission();
      await _getCurrentLocation();
      await _fetchGeofenceData();
      _startLocationMonitoring();
      setState(() => isLoading = false);
    } catch (e) {
      print("Error initializing data: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      throw Exception('Location permission denied');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error getting location: $e");
      rethrow;
    }
  }

  Future<void> _fetchGeofenceData() async {
    try {
      final token =
          SharedPrefUtil.getValue(constant.accessTokenPref, "") as String;

      final response = await http.get(
        Uri.parse('${CallHelper.baseUrl}api/user/location/getGeofence'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final geometry = jsonData['data']['geometry'];
        final coordinates = geometry['coordinates'];

        if (geometry['type'] == 'Polygon') {
          _addPolygon(coordinates[0]);
        } else if (geometry['type'] == 'MultiPolygon') {
          for (var polygon in coordinates) {
            _addPolygon(polygon[0]);
          }
        }
      } else {
        throw Exception('Failed to load geofence data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching geofence: $e");
      rethrow;
    }
  }

  void _addPolygon(List<dynamic> coordinates) {
    final polygonPoints = coordinates
        .map<LatLng>((coord) => LatLng(coord[1] as double, coord[0] as double))
        .toList();

    setState(() {
      polygons.add(Polygon(
        polygonId: PolygonId('geofence_${polygons.length}'),
        points: polygonPoints,
        strokeWidth: 4,
        strokeColor: Colors.green,
        fillColor: Colors.green.withOpacity(0.15),
      ));
    });
  }

  void _startLocationMonitoring() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() => currentLocation = newLocation);
      _checkGeofenceStatus(newLocation);
    });
  }

  void _checkGeofenceStatus(LatLng location) {
    bool isInside = _isInsideAnyPolygon(location);

    if (!isInside && isInsideGeofence) {
      // User exited the geofence
      NotificationService.triggerTestNotification(
        title: 'Boundary Alert',
        body: 'You have left the training area!',
      );
    }

    setState(() => isInsideGeofence = isInside);
  }

  bool _isInsideAnyPolygon(LatLng point) {
    for (Polygon polygon in polygons) {
      if (_isPointInPolygon(point, polygon.points)) {
        return true;
      }
    }
    return false;
  }

  bool _isPointInPolygon(LatLng testPoint, List<LatLng> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if (((polygon[i].latitude > testPoint.latitude) !=
              (polygon[j].latitude > testPoint.latitude)) &&
          (testPoint.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (testPoint.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude)) {
        inside = !inside;
      }
    }
    return inside;
  }

  void _adjustCamera() {
    if (mapController == null ||
        (currentLocation == null && polygons.isEmpty)) {
      return;
    }

    List<LatLng> allPoints = [];
    if (currentLocation != null) allPoints.add(currentLocation!);
    if (polygons.isNotEmpty) allPoints.addAll(polygons.first.points);
    if (allPoints.isEmpty) return;

    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (LatLng point in allPoints) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    mapController.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      50,
    ));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) => _adjustCamera());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onBackground),
        title: Text(
          'Training Area',
          style: theme.textTheme.displayLarge,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : hasError
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: colors.error),
                        const SizedBox(height: 24),
                        Text(
                          'No training for this Area',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colors.onBackground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _initializeData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Try Again',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: currentLocation ?? const LatLng(0, 0),
                        zoom: 12,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      polygons: polygons,
                      mapType: MapType.normal,
                      compassEnabled: true,
                      zoomControlsEnabled: false,
                      style: _mapStyle,
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: FloatingActionButton(
                        backgroundColor: primaryColor,
                        child:
                            const Icon(Icons.my_location, color: Colors.white),
                        onPressed: () {
                          if (currentLocation != null) {
                            mapController.animateCamera(
                              CameraUpdate.newLatLng(currentLocation!),
                            );
                          }
                        },
                      ),
                    ),
                    if (!isInsideGeofence)
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.red.withOpacity(0.7),
                          child: const Text(
                            'You have left the training area!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  String get _mapStyle => '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#1d1d1d"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#2c2c2c"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#9ca5b3"
        }
      ]
    }
  ]
  ''';
}
