import 'package:cartie/features/login_signup_flow/password_screen.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:cartie/core/utills/branded_primary_button.dart';
import 'package:provider/provider.dart';

class VerificationScreen extends StatefulWidget {
  final String emailId;
  final bool? isForget;
  const VerificationScreen(
      {required this.emailId, this.isForget = false, super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String _otpCode = "";

  void _verifyCode() async {
    if (_otpCode.length != 4) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Invalid Code"),
          content: Text("Please enter the 4-digit verification code."),
        ),
      );
      return;
    }

    final userViewModel = context.read<UserViewModel>();
    final response = await userViewModel.verifyOtp(widget.emailId, _otpCode);

    if (response.success) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => CreatePasswordScreen(
                email: widget.emailId, isForgetPassword: widget.isForget!)),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Verification Failed"),
          content: Text(response.message),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final height = MediaQuery.of(context).size.height;

    return Consumer<UserViewModel>(
      builder: (context, userProvider, child) {
        return Scaffold(
          appBar: AppBar(),
          backgroundColor: colorScheme.background,
          body: userProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ListView(
                    children: [
                      SizedBox(height: height * 0.1),
                      Center(
                        child: Text(
                          "Verification Code",
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onBackground,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          "We sent a verification code to your email. Check your inbox.",
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          "Enter Your Verification Code Here.",
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onBackground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.1),
                      PinCodeTextField(
                        length: 4,
                        onChanged: (value) => _otpCode = value,
                        appContext: context,
                        textStyle: textTheme.headlineLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        cursorColor: colorScheme.primary,
                        keyboardType: TextInputType.number,
                        backgroundColor: Colors.transparent,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.underline,
                          inactiveColor:
                              colorScheme.onBackground.withOpacity(0.4),
                          activeColor: colorScheme.primary,
                          selectedColor: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      BrandedPrimaryButton(
                        name: "Verify",
                        isEnabled: true,
                        onPressed: _verifyCode,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
