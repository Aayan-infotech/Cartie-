import 'dart:async';
import 'dart:convert';
import 'package:cartie/core/theme/app_theme.dart';
import 'package:cartie/core/utills/branded_primary_button.dart';
import 'package:cartie/core/utills/constant.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _searchController = TextEditingController();
  List<Prediction> _predictions = [];
  bool _isLoading = false;
  LatLng? _targetLatLng; // Make nullable to track selection state

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(51.5416, -0.1431),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleTextChange);
    _searchController.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _predictions = [];
        _targetLatLng = null; // Clear coordinates when text is cleared
      });
    } else {
      setState(() {
        _targetLatLng = null; // Invalidate previous selection on text change
      });
      _searchPlaces(_searchController.text);
    }
  }

  Future<void> _searchPlaces(String input) async {
    if (input.isEmpty) return;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
      'input=$input&key=$kGoogleApiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _predictions = (data['predictions'] as List)
            .map<Prediction>((p) => Prediction.fromJson(p))
            .toList();
      });
    }
  }

  Future<void> _selectPlace(String placeId, String description) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?'
      'place_id=$placeId&key=$kGoogleApiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      final lat = location['lat'] as double;
      final lng = location['lng'] as double;
      final target = LatLng(lat, lng);

      setState(() {
        _targetLatLng = target;
        _predictions = [];
      });

      // Update text without triggering listener
      _searchController
        ..removeListener(_handleTextChange)
        ..text = description
        ..addListener(_handleTextChange);

      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(target));
    }
  }

  void _submitLocation() async {
    final placeName = _searchController.text.trim();

    // Validate both fields
    if (placeName.isEmpty || _targetLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a valid location")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final viewModel = Provider.of<UserViewModel>(context, listen: false);
      var response = await viewModel.addLocation(placeName, _targetLatLng!);
      if (response.success) {
        AppTheme.showSuccessDialog(context, "Location updated successfully",
            onConfirm: () => Navigator.of(context).pop());
      } else {
        AppTheme.showSuccessDialog(context, response.message,
            onConfirm: () => Navigator.of(context).pop());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add location: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isButtonEnabled =
        _searchController.text.isNotEmpty && _targetLatLng != null;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialPosition,
                  onMapCreated: (controller) =>
                      _mapController.complete(controller),
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                ),
                Positioned(
                  top: height * 0.07,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter Location",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.6),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                        ),
                      ),
                      if (_predictions.isNotEmpty)
                        Container(
                          color: Colors.black.withOpacity(0.6),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _predictions.length,
                            itemBuilder: (context, index) => ListTile(
                              title: Text(_predictions[index].description,
                                  style: const TextStyle(color: Colors.white)),
                              onTap: () => _selectPlace(
                                _predictions[index].placeId,
                                _predictions[index].description,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BrandedPrimaryButton(
                      isEnabled: isButtonEnabled,
                      name: "Select",
                      onPressed: _submitLocation,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class Prediction {
  final String description;
  final String placeId;

  Prediction({required this.description, required this.placeId});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      description: json['description'] as String,
      placeId: json['place_id'] as String,
    );
  }
}
