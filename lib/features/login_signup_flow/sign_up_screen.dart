import 'package:cartie/core/utills/branded_primary_button.dart';
import 'package:cartie/core/utills/branded_text_filed.dart';
import 'package:cartie/core/utills/mobile_number_field.dart';
import 'package:cartie/features/login_signup_flow/verificatio_screen.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:country_code_text_field/country_code_text_field.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController _mobileontroller = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  

  void _validateAndSubmit() async {
    if (_formKey.currentState!.validate()) {
      final name = _firstNameController.text.trim() +
          " " +
          _lastNameController.text.trim();
      final email = _emailController.text.trim();
      final state = _stateController.text.trim();

      final userViewModel = Provider.of<UserViewModel>(context, listen: false);

      var response =
          await userViewModel.signUp(name, _mobileontroller.text, state, email);

      if (response.success) {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => VerificationScreen(
                    emailId: email,
                  )),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Signup Failed"),
            content: Text(userViewModel.errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
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
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: userViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                autovalidateMode:
                    AutovalidateMode.onUserInteraction, // Add this line
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
                    BrandedTextField(
                      controller: _firstNameController,
                      labelText: "First Name",
                      isFilled: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your first name";
                        }
                        if (!RegExp(r'^[A-Z]').hasMatch(value.trim())) {
                          return "First name should start with a capital letter";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    BrandedTextField(
                      controller: _lastNameController,
                      labelText: "Last Name",
                      isFilled: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your last name";
                        }
                        if (!RegExp(r'^[A-Z]').hasMatch(value.trim())) {
                          return "Last name should start with a capital letter";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    CustomPhoneTextField(
                      initialCountryCode: 'IN',
                      labelText: 'Phone Number',
                      onChanged: (phone) {
                        _mobileontroller.text = phone.completeNumber;
                      },
                    ),

                    // BrandedTextField(
                    //   controller: _mobileontroller,
                    //   keyboardType: TextInputType.phone,
                    //   labelText: "Mobile",
                    //   isFilled: true,
                    //   validator: (value) {
                    //     if (value == null || value.trim().isEmpty) {
                    //       return "Please enter your mobile number"; // Fixed error message
                    //     }
                    //     return null;
                    //   },
                    // ),
                    const SizedBox(height: 20),
                    BrandedTextField(
                      controller: _emailController,
                      labelText: "Email",
                      isFilled: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your email";
                        }
                        // Optionally add email format validation
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    BrandedTextField(
                      controller: _stateController,
                      labelText: "Address",
                      isFilled: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your state";
                        }
                        return null;
                      },
                    ),
                    // const Spacer(),
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
                          onPressed: () => Navigator.of(context).pop(),
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
}
