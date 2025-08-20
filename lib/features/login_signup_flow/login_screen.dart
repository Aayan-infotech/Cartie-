import 'package:cartie/core/theme/app_theme.dart';
import 'package:cartie/core/utills/branded_primary_button.dart';
import 'package:cartie/core/utills/branded_text_filed.dart';
import 'package:cartie/core/utills/constant.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';
import 'package:cartie/features/dashboard/dashboard_screen.dart';
import 'package:cartie/features/login_signup_flow/forget_password_screen.dart';
import 'package:cartie/features/login_signup_flow/location_services.dart';
import 'package:cartie/features/login_signup_flow/sign_up_screen.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _validateAndLogin() async {
    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    final emailOrPhone = _emailOrPhoneController.text.trim();
    final password = _passwordController.text.trim();

    // Validate fields and show dialog for errors
    if (emailOrPhone.isEmpty) {
      _showValidationError("Please enter email or phone number");
      return;
    }

    if (password.isEmpty) {
      _showValidationError("Password is required");
      return;
    }

    if (password.length < 8) {
      _showValidationError("Password must be at least 8 characters");
      return;
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      _showValidationError("Password must contain at least one number");
      return;
    }

    if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
      _showValidationError(
          "Password must contain at least one special character");
      return;
    }

    // All validations passed - proceed with login
    FocusScope.of(context).unfocus();

    final response = await viewModel.login(emailOrPhone, password);

    if (response.success) {
      final data = response.data['data'];
      await _storeAuthData(data);
      await viewModel.getUserProfile(data['accessToken'], data['userId']);

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LocationPermissionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
                position: animation.drive(tween), child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    } else {
      AppTheme.showErrorDialog(context, response.message);
    }
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Validation Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _storeAuthData(Map<String, dynamic> data) async {
    await SharedPrefUtil.setValue(isLoginPref, true);
    await SharedPrefUtil.setValue(accessTokenPref, data['accessToken']);
    await SharedPrefUtil.setValue(refreshTokenPref, data['refreshToken']);
    await SharedPrefUtil.setValue(userIdPref, data['userId']);
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
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgetPasswordScreen(),
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
                        suffixIcon: viewModel.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
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
                                    builder: (context) => const SignUpScreen(),
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
    );
  }
}
