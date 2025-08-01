import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
// import 'package:audioplayers/audioplayers.dart';
import 'package:cartie/core/api_services/call_helper.dart';
import 'package:cartie/core/utills/constant.dart' as constant;
import 'package:cartie/core/utills/notification_services.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

class TrainingMapScreen extends StatefulWidget {
  @override
  _TrainingMapScreenState createState() => _TrainingMapScreenState();
}

class _TrainingMapScreenState extends State<TrainingMapScreen>
    with WidgetsBindingObserver {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  Set<Polygon> polygons = {};
  bool isLoading = true;
  bool hasError = false;
  bool isInsideGeofence = true;
  bool isAppInForeground = true;
  bool isWarningActive = false;
  StreamSubscription<Position>? positionStream;
  Timer? _periodicCheckTimer;
  // final AudioPlayer _audioPlayer = AudioPlayer();
  Completer<AlertDialog>? _activeDialogCompleter;

  final Color primaryColor = Colors.red[900]!;
  final Color accentColor = Colors.redAccent;
  final Color backgroundColor = Colors.black;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
    _startPeriodicChecks();
    _setupAudio();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      isAppInForeground = state == AppLifecycleState.resumed;
    });

    if (state == AppLifecycleState.resumed && !isInsideGeofence) {
      _showIntenseWarning();
    }
  }

  void _setupAudio() async {
    // await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // await _audioPlayer.setSourceAsset('sounds/alarm.mp3');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    positionStream?.cancel();
    _periodicCheckTimer?.cancel();
    // _audioPlayer.dispose();
    _dismissActiveDialog();
    super.dispose();
  }

  void _dismissActiveDialog() {
    if (_activeDialogCompleter != null &&
        !_activeDialogCompleter!.isCompleted) {
      Navigator.of(context, rootNavigator: true).pop();
      _activeDialogCompleter = null;
    }
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    try {
      if (Platform.isAndroid) {
        await _requestLocationPermission();
      }
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

      // _showPermissionErrorDialog(e.toString());
    }
  }

  Future<void> _showPermissionErrorDialog(String error) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text(
          'This app requires location permissions to function properly. '
          'Error: $error\n\nPlease enable location permissions in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      if (Platform.isIOS) {
        status = await Permission.locationWhenInUse.request();
        if (status.isGranted) {
          status = await Permission.locationAlways.request();
        }
      } else {
        status = await Permission.location.request();
      }
    }

    if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog();
      throw Exception('Location permission permanently denied');
    }

    if (!status.isGranted) {
      throw Exception('Location permission denied');
    }

    if (Platform.isIOS) {
      await _checkPreciseLocation();
    }
  }

  Future<void> _checkPreciseLocation() async {
    if (await Permission.locationWhenInUse.serviceStatus.isDisabled) {
      throw Exception('Location services are disabled');
    }

    final accuracy = await Geolocator.getLocationAccuracy();
    if (accuracy == LocationAccuracyStatus.reduced) {
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Precise Location Required'),
          content: Text(
            'This app requires precise location to accurately monitor your position. '
            'Please enable Precise Location in Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Open Settings'),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        await openAppSettings();
        throw Exception('Precise location not enabled');
      }
    }
  }

  Future<void> _showPermissionDeniedDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Denied'),
        content: Text(
          'This app requires location permissions to function properly. '
          'You have permanently denied location permissions. '
          'Please enable them in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _startPeriodicChecks() {
    _periodicCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (currentLocation != null) {
        _checkGeofenceStatus(currentLocation!);
      } else {
        _getCurrentLocation().then((_) {
          if (currentLocation != null) {
            _checkGeofenceStatus(currentLocation!);
          }
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() => currentLocation = newLocation);

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(newLocation),
        );
      }
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
      distanceFilter: 10,
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
    bool isCurrentlyInside = _isInsideAnyPolygon(location);

    if (!isCurrentlyInside && isInsideGeofence) {
      _triggerIntenseWarning();
    } else if (isCurrentlyInside && !isInsideGeofence) {
      _cancelIntenseWarning();
    }

    setState(() => isInsideGeofence = isCurrentlyInside);
  }

  void _triggerIntenseWarning() {
    NotificationService.triggerTestNotification(
      title: 'BOUNDARY BREACHED!',
      body: 'RETURN TO TRAINING AREA IMMEDIATELY!',
    );

    Vibration.vibrate(pattern: [500, 1000, 500, 1000, 500, 2000]);
    // _audioPlayer.resume();

    if (isAppInForeground) {
      _showIntenseWarning();
    }

    setState(() => isWarningActive = true);
  }

  void _cancelIntenseWarning() {
    // _audioPlayer.pause();
    Vibration.cancel();
    _dismissActiveDialog();
    setState(() => isWarningActive = false);
  }

  Future<void> _showIntenseWarning() async {
    _dismissActiveDialog();

    final completer = Completer<AlertDialog>();
    _activeDialogCompleter = completer;

    SystemSound.play(SystemSoundType.alert);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.red[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.yellow, size: 36),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  'BOUNDARY ALERT!',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'You have left the authorized training area!\n\nReturn immediately to avoid disciplinary action.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'ACKNOWLEDGE',
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // _audioPlayer.pause();
                Vibration.cancel();
                Navigator.of(context).pop();
                completer.complete();
              },
            ),
          ],
        ),
      ),
    );

    if (completer == _activeDialogCompleter) {
      _activeDialogCompleter = null;
    }
  }

  bool _isInsideAnyPolygon(LatLng testPoint) {
    for (Polygon polygon in polygons) {
      if (_isPointInPolygon(testPoint, polygon.points)) {
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
    if (mapController == null || polygons.isEmpty) return;

    List<LatLng> allPoints = [];
    for (var polygon in polygons) {
      allPoints.addAll(polygon.points);
    }

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

    final padding = (maxLat - minLat) * 0.1;
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      50,
    ));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    if (currentLocation != null) {
      controller.animateCamera(
        CameraUpdate.newLatLng(currentLocation!),
      );
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (polygons.isNotEmpty) _adjustCamera();
    });
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
                        zoom: 16,
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
                            mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(currentLocation!, 16),
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
                          decoration: BoxDecoration(
                            color: Colors.red[900],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning, color: Colors.yellow),
                              SizedBox(width: 10),
                              Text(
                                'ALERT: You left the training area!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
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
