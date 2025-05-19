import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class TrainingMapScreen extends StatefulWidget {
  @override
  _TrainingMapScreenState createState() => _TrainingMapScreenState();
}

class _TrainingMapScreenState extends State<TrainingMapScreen> {
  late GoogleMapController mapController;
  LatLng? currentLocation;
  Polyline? circlePolyline;
  Set<Polyline> polylines = {};

  final Color primaryColor = Colors.red[900]!;
  final Color accentColor = Colors.redAccent;
  final Color backgroundColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      _createPolylineCircle(position.latitude, position.longitude);
    });
  }

  void _createPolylineCircle(double lat, double lng) {
    const double radius = 5000; // 5km in meters
    final List<LatLng> circlePoints = [];

    // Generate points for the circle
    for (int i = 0; i <= 360; i++) {
      double angle = i * pi / 180;
      double dx = radius * cos(angle);
      double dy = radius * sin(angle);

      circlePoints.add(LatLng(
        lat + (dx / 111319.5),
        lng + (dy / (111319.5 * cos(lat * pi / 180))),
      ));
    }

    // Close the circle by adding the first point again
    circlePoints.add(circlePoints[0]);

    setState(() {
      circlePolyline = Polyline(
        polylineId: PolylineId('trainingArea'),
        points: circlePoints,
        color: primaryColor.withOpacity(0.8),
        width: 4,
        geodesic: true,
        jointType: JointType.round,
      );

      polylines.add(circlePolyline!);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Training Area',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: currentLocation!,
                    zoom: 12,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  polylines: polylines,
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
                    child: Icon(Icons.my_location, color: Colors.white),
                    onPressed: () {
                      mapController.animateCamera(
                        CameraUpdate.newLatLng(currentLocation!),
                      );
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
