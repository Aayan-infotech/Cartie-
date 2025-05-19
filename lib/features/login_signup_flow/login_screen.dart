import 'package:cartie/core/theme/app_theme.dart';
import 'package:cartie/core/utills/branded_primary_button.dart';
import 'package:cartie/core/utills/branded_text_filed.dart';
import 'package:cartie/core/utills/constant.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';
import 'package:cartie/core/utills/user_context_data.dart';
import 'package:cartie/features/dashboard/dashboard_screen.dart';
import 'package:cartie/features/login_signup_flow/forget_password_screen.dart';
import 'package:cartie/features/login_signup_flow/location_services.dart';
import 'package:cartie/features/login_signup_flow/sign_up_screen.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _validateAndLogin() async {
    final viewModel = Provider.of<UserViewModel>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      var response = await viewModel.login(
        _emailOrPhoneController.text.trim(),
        _passwordController.text.trim(),
      );

      if (response.success) {
        var data = response.data['data'];
        SharedPrefUtil.setValue(isLoginPref, true);
        SharedPrefUtil.setValue(accessTokenPref, data['accessToken']);
        SharedPrefUtil.setValue(refreshTokenPref, data['refreshToken']);
        SharedPrefUtil.setValue(userIdPref, data['userId']);
        await viewModel.getUserProfile(data['accessToken'],data['userId']);

        // Navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
        );
      } else {
        AppTheme.showErrorDialog(context, response.message);
      }
    }
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Must contain at least one number';
    }
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      return 'Must contain at least one special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final viewModel = Provider.of<UserViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                color: colorScheme.primary,
                                size: 60,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Welcome Back",
                                style: textTheme.displayLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Please sign in to continue",
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        BrandedTextField(
                          controller: _emailOrPhoneController,
                          labelText: "Email or Phone Number",
                          isFilled: true,
                          prefix: Icon(
                            Icons.alternate_email_rounded,
                            color: theme.iconTheme.color,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter email or phone number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        BrandedTextField(
                            controller: _passwordController,
                            labelText: "Password",
                            isFilled: true,
                            isPassword: true,
                            prefix: Icon(
                              Icons.lock_outline_rounded,
                              color: theme.iconTheme.color,
                            ),
                            validator: _passwordValidator),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgetPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        BrandedPrimaryButton(
                          isEnabled: true,
                          name: "Log In",
                          onPressed: _validateAndLogin,
                          suffixIcon: Icon(
                            Icons.arrow_forward_rounded,
                            size: 24,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: textTheme.bodyLarge?.copyWith(
                                  color:
                                      colorScheme.onBackground.withOpacity(0.6),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
