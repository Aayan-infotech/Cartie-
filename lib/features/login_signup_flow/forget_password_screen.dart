import 'package:cartie/core/theme/app_theme.dart';
import 'package:cartie/core/utills/branded_text_filed.dart';
import 'package:cartie/features/login_signup_flow/verificatio_screen.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:cartie/core/utills/branded_primary_button.dart';
import 'package:provider/provider.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitResetLink() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<UserViewModel>(context, listen: false);
      var response = await authProvider.forgotPassword(_emailController.text);
      if (response.success) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return VerificationScreen(
            emailId: _emailController.text,
            isForget: true,
          );
        }));
      } else {
        AppTheme.showErrorDialog(context, response.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: Consumer<UserViewModel>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: height * 0.04),
                              Center(
                                child: Icon(
                                  Icons.lock_reset,
                                  color: colorScheme.primary,
                                  size: 80,
                                ),
                              ),
                              SizedBox(height: height * 0.04),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      "Forgot Password?",
                                      style: textTheme.headlineSmall?.copyWith(
                                        color: colorScheme.onBackground,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Enter your email or mobile number to receive\na password reset link",
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onBackground
                                            .withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: height * 0.08),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: BrandedTextField(
                                  isEnabled: true,
                                  labelText: "Email",
                                  isFilled: true,
                                  controller: _emailController,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Please enter your email";
                                    }
                                    // Optionally add email format validation
                                    if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return "Please enter a valid email";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const Spacer(),
                              BrandedPrimaryButton(
                                name: "Submit",
                                isEnabled: true,
                                onPressed: _submitResetLink,
                              ),
                              SizedBox(height: height * 0.04),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
