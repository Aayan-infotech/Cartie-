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
  Set<Polyline> polylines = {};

  final Color primaryColor = Colors.red[900]!;
  final Color accentColor = Colors.redAccent;
  final Color backgroundColor = Colors.black;

  // Predefined polyline coordinates
  final List<List<double>> predefinedPolylineCoordinates = [
    [23.83766000000014, 19.580470000000105],
    [23.886890000000108, 15.61084],
    [23.024590000000103, 15.68072],
    [22.56795000000011, 14.944290000000137],
    [22.30351, 14.32682],
    [22.51202, 14.09318],
    [22.18329, 13.78648],
    [22.29658, 13.37232],
    [22.03759, 12.95546],
    [21.93681, 12.588180000000136],
    [22.28801, 12.64605],
    [22.49762, 12.26024],
    [22.50869, 11.67936],
    [22.87622, 11.384610000000123],
    [22.864165480244225, 11.142395127807546],
    [22.23112918466876, 10.97188873946061],
    [21.723821648859456, 10.567055568885976],
    [21.000868361096167, 9.475985215691509],
    [20.05968549976427, 9.012706000194854],
    [19.09400800952602, 9.07484691002584],
    [18.812009718509273, 8.982914536978598],
    [18.911021762780507, 8.630894680206353],
    [18.38955488452322, 8.281303615751824],
    [17.964929640380888, 7.890914008002994],
    [16.705988396886255, 7.508327541529979],
    [16.456184523187346, 7.734773667832968],
    [16.290561557691888, 7.754307359239419],
    [16.106231723706742, 7.497087917506462],
    [15.279460483469109, 7.421924546737969],
    [15.436091749745742, 7.692812404811889],
    [15.120865512765306, 8.382150173369439],
    [14.97999555833769, 8.796104234243472],
    [14.54446658698177, 8.965861314322268],
    [13.954218377344006, 9.549494940626687],
    [14.171466098699028, 10.021378282099931],
    [14.62720055508106, 9.920919297724538],
    [14.909353875394716, 9.992129421422732],
    [15.467872755605242, 9.982336737503545],
    [14.92356489427496, 10.891325181517473],
    [14.9601518083376, 11.555574042197224],
    [14.89336, 12.21905],
    [14.495787387762846, 12.85939626713733],
    [14.595781284247607, 13.33042694747786],
    [13.95447675950561, 13.353448798063766],
    [13.956698846094127, 13.996691189016929],
    [13.540393507550789, 14.367133693901224],
    [13.97217, 15.68437],
    [15.247731154041844, 16.627305813050782],
    [15.30044111497972, 17.927949937405003],
    [15.685740594147774, 19.957180080642388],
    [15.903246697664315, 20.387618923417506],
    [15.487148064850146, 20.730414537025638],
    [15.47106, 21.04845],
    [15.096887648181848, 21.30851878507491],
    [14.8513, 22.862950000000126],
    [15.86085, 23.40972],
    [19.84926, 21.49509],
    [23.83766000000014, 19.580470000000105]
  ];
  void _moveCameraToPolylineBounds() {
    List<LatLng> points = predefinedPolylineCoordinates
        .map((coord) => LatLng(coord[0], coord[1]))
        .toList();

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }



  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _createPredefinedPolyline();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _createPredefinedPolyline() {
    List<LatLng> points = predefinedPolylineCoordinates
        .map((coord) => LatLng(coord[0], coord[1]))
        .toList();

    Polyline predefinedPolyline = Polyline(
      polylineId: const PolylineId('predefinedPolyline'),
      points: points,
      color: Colors.green, //primaryColor.withOpacity(0.8),
      width: 4,
      geodesic: true,
      jointType: JointType.round,
    );

    setState(() {
      polylines.add(predefinedPolyline);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _moveCameraToPolylineBounds(); // Center map on polyline
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
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
