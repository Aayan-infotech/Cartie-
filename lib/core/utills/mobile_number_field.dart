import 'package:country_code_text_field/country_code_text_field.dart';
import 'package:country_code_text_field/phone_number.dart';
import 'package:flutter/material.dart';

class CustomPhoneTextField extends StatelessWidget {
  final String initialCountryCode;
  final void Function(PhoneNumber) onChanged;
  final String labelText;
  final Color? backgroundColor;
  final bool isFilled;
  final bool isEnabled;
  final String? Function(String?)? validator;
  final TextEditingController? controller; // Added controller

  const CustomPhoneTextField({
    super.key,
    required this.initialCountryCode,
    required this.onChanged,
    this.labelText = 'Phone Number',
    this.backgroundColor,
    this.isFilled = true,
    this.isEnabled = true,
    this.validator,
    this.controller, // Constructor parameter
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CountryCodeTextField(
      enabled: isEnabled,
      initialCountryCode: initialCountryCode,
      onChanged: onChanged,
      controller: controller, // Used here
      decoration: InputDecoration(
        labelText: labelText,
        filled: isFilled,
        fillColor: backgroundColor ?? theme.inputDecorationTheme.fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
      ),
      // validator: validator, // Uncomment if the CountryCodeTextField supports validator
    );
  }
}
