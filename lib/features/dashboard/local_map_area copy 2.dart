import 'dart:convert';
import 'dart:math';
import 'package:cartie/core/api_services/call_helper.dart';
import 'package:cartie/core/utills/constant.dart' as constant;
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

  final Color primaryColor = Colors.red[900]!;
  final Color accentColor = Colors.redAccent;
  final Color backgroundColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });
    try {
      //  await _getCurrentLocation();
      await _fetchGeofenceData();
    } catch (e) {
      print("Error initializing data: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  // Future<void> _getCurrentLocation() async {
  //   try {
  //     var status = await Permission.location.request();
  //     if (!status.isGranted) {
  //       throw Exception('Location permission denied');
  //     }

  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );

  //     setState(() {
  //       currentLocation = LatLng(position.latitude, position.longitude);
  //     });
  //   } catch (e) {
  //     print("Error getting location: $e");
  //     rethrow;
  //   }
  // }

  // Future<void> _fetchGeofenceData() async {
  //   try {
  //     final token = SharedPrefUtil.getValue(constant.accessTokenPref, "")
  //         as String; // Or however you retrieve your token

  //     final response = await http.get(
  //       Uri.parse('${CallHelper.baseUrl}api/user/location/getGeofence'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final jsonData = json.decode(response.body);
  //       final geometry = jsonData['data']['geometry'];

  //       if (geometry['type'] == 'Polygon') {
  //         final coordinates = geometry['coordinates'][0];
  //         final polygonPoints = coordinates
  //             .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
  //             .toList();

  //         setState(() {
  //           polygons.add(Polygon(
  //             polygonId: const PolygonId('geofence'),
  //             points: polygonPoints,
  //             strokeWidth: 4,
  //             strokeColor: Colors.green,
  //             fillColor: Colors.green.withOpacity(0.15),
  //           ));
  //         });
  //       }
  //     } else {
  //       throw Exception('Failed to load geofence data: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print("Error fetching geofence: $e");
  //     rethrow;
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }
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
          _addPolygon(coordinates[0]); // Handle Polygon coordinates
        } else if (geometry['type'] == 'MultiPolygon') {
          for (var polygon in coordinates) {
            _addPolygon(polygon[0]); // Handle each polygon in MultiPolygon
          }
        }
      } else {
        throw Exception('Failed to load geofence data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching geofence: $e");
      rethrow;
    } finally {
      setState(() => isLoading = false);
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

  void _adjustCamera() {
    if (mapController == null ||
        (currentLocation == null && polygons.isEmpty)) {
      return;
    }

    List<LatLng> allPoints = [];

    if (currentLocation != null) {
      allPoints.add(currentLocation!);
    }

    if (polygons.isNotEmpty) {
      allPoints.addAll(polygons.first.points);
    }

    if (allPoints.isEmpty) return;

    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (LatLng point in allPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) => _adjustCamera());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   title: const Text(
      //     'Training Area',
      //     style: TextStyle(
      //       color: Colors.white,
      //       fontWeight: FontWeight.bold,
      //       fontSize: 24,
      //     ),
      //   ),
      //   centerTitle: true,
      //   iconTheme: const IconThemeData(color: Colors.white),
      // ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : hasError
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colors.error,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No training for this Area',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colors.onBackground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Text(
                        //   errorMessage ?? 'Unknown error occurred',
                        //   style: theme.textTheme.bodyMedium?.copyWith(
                        //     color: colors.onBackground.withOpacity(0.7),
                        //   ),
                        //   textAlign: TextAlign.center,
                        // ),
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
