import 'package:cartie/core/utills/branded_primary_button.dart';
import 'package:cartie/core/utills/branded_text_filed.dart';
import 'package:cartie/core/utills/mobile_number_field.dart';
import 'package:cartie/features/login_signup_flow/verificatio_screen.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  void _validateAndSubmit() async {
    if (_formKey.currentState!.validate()) {
      final name =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      final email = _emailController.text.trim();
      final address =
          '${_streetAddressController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()} ${_zipCodeController.text.trim()}';

      final userViewModel = Provider.of<UserViewModel>(context, listen: false);

      var response = await userViewModel.signUp(
        name,
        _mobileController.text,
        address,
        email,
      );

      if (response.success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(emailId: email),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Signup Failed"),
            content: Text(userViewModel.errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  String capitalizeName(String name) {
    return name
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  void _getCurrentLocation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _streetAddressController.text =
              '${place.street ?? ''} ${place.thoroughfare ?? ''}'.trim();
          _cityController.text = place.locality ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _zipCodeController.text = place.postalCode ?? '';
        });
      }
      Navigator.of(context).pop(); // Close loading dialog
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog first
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Location Error"),
          content: Text("Could not fetch location: ${e.toString()}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _fetchCityStateFromZip(String zipCode) async {
    if (zipCode.length >= 5) {
      try {
        List<Location> locations = await locationFromAddress(zipCode);
        if (locations.isNotEmpty) {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            locations.first.latitude,
            locations.first.longitude,
          );

          if (placemarks.isNotEmpty) {
            setState(() {
              _cityController.text = placemarks.first.locality ?? '';
              _stateController.text = placemarks.first.administrativeArea ?? '';
            });
          }
        }
      } catch (e) {
        // Handle API errors silently
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(forceMaterialTransparency: true),
      body: userViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        "Create App account!",
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Text(
                        "Maybe some tagline here",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Existing name fields
                    BrandedTextField(
                      controller: _firstNameController,
                      labelText: "First Name",
                      isFilled: true,
                      onChanged: (value) {
                        final formatted = capitalizeName(value);
                        if (value != formatted) {
                          _firstNameController.value =
                              _firstNameController.value.copyWith(
                            text: formatted,
                            selection: TextSelection.collapsed(
                                offset: formatted.length),
                          );
                        }
                      },
                      validator: (value) => _validateName(value, "first"),
                    ),
                    const SizedBox(height: 20),
                    BrandedTextField(
                      controller: _lastNameController,
                      labelText: "Last Name",
                      isFilled: true,
                      onChanged: (value) {
                        final formatted = capitalizeName(value);
                        if (value != formatted) {
                          _lastNameController.value =
                              _lastNameController.value.copyWith(
                            text: formatted,
                            selection: TextSelection.collapsed(
                                offset: formatted.length),
                          );
                        }
                      },
                      validator: (value) => _validateName(value, "last"),
                    ),
                    const SizedBox(height: 20),
                    CustomPhoneTextField(
                      initialCountryCode: 'US',
                      labelText: 'Phone Number',
                      onChanged: (phone) =>
                          _mobileController.text = phone.completeNumber,
                    ),
                    const SizedBox(height: 20),
                    BrandedTextField(
                      controller: _emailController,
                      labelText: "Email",
                      isFilled: true,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 20),
                    // New address fields
                    BrandedTextField(
                      controller: _streetAddressController,
                      labelText: "Street Address",
                      isFilled: true,
                      validator: _validateStreetAddress,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: BrandedTextField(
                            controller: _cityController,
                            labelText: "City",
                            isFilled: true,
                            validator: _validateCity,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: BrandedTextField(
                            controller: _stateController,
                            labelText: "State",
                            isFilled: true,
                            validator: _validateState,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: BrandedTextField(
                            controller: _zipCodeController,
                            labelText: "Zip Code",
                            isFilled: true,
                            keyboardType: TextInputType.number,
                            validator: _validateZipCode,
                            onChanged: _fetchCityStateFromZip,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.location_on_outlined,
                              color: colorScheme.primary),
                          onPressed: _getCurrentLocation,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Existing sign up button and login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Log In",
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    BrandedPrimaryButton(
                      isEnabled: true,
                      name: "Sign up",
                      onPressed: _validateAndSubmit,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  String? _validateName(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your $field name";
    }
    if (!RegExp(r'^[A-Z]').hasMatch(value.trim())) {
      return "${field.capitalize()} name should start with a capital letter";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your email";
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  String? _validateStreetAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your street address";
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your city";
    }
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your state";
    }
    return null;
  }

  String? _validateZipCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your zip code";
    }
    // Accepts 5 or 6 digits only
    if (!RegExp(r'^\d{5,6}$').hasMatch(value)) {
      return "Please enter a valid zip code";
    }
    return null;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
