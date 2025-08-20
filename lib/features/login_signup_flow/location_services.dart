import 'package:cartie/core/theme/app_theme.dart';
import 'package:cartie/core/utills/location.dart';
import 'package:cartie/core/utills/user_context_data.dart';
import 'package:cartie/features/dashboard/dashboard_screen.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  final viewModel = UserViewModel(); // ideally use Provider

  @override
  void initState() {
    super.initState();
    _handleLocation();
  }

  Future<void> _handleLocation() async {
    try {
      final position =
          await LocationService.getCurrentLocationWithPermission(context);
      final placeName =
          await LocationService.getPlaceNameFromCoordinates(position);

      await viewModel.addLocation(
          placeName, LatLng(position.latitude, position.longitude));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
