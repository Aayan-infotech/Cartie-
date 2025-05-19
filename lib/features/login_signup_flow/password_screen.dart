import 'package:cartie/core/theme/app_theme.dart';
import 'package:cartie/features/login_signup_flow/login_screen.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:cartie/core/utills/branded_text_filed.dart';
import 'package:cartie/core/utills/branded_primary_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class CreatePasswordScreen extends StatefulWidget {
  final bool isChangePassword;
  final bool isForgetPassword;
  final String? email;

  CreatePasswordScreen({
    this.isChangePassword = false,
    this.isForgetPassword = false,
    this.email = '',
    super.key,
  });

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _oldPasswordController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.location.request();
    if (!status.isGranted) {
      // Handle permission denial if needed
    }
  }

  String? _oldPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Old password is required';
    }
    return null;
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

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _submitPassword(UserViewModel userVM) async {
    if (!_formKey.currentState!.validate()) return;

    await userVM.setPassword(widget.email!, _passwordController.text);

    if (userVM.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userVM.errorMessage)),
      );
      return;
    }

    await _requestPermissions();

    if (widget.isChangePassword) {
      Navigator.pop(context);
    } else if (widget.isForgetPassword) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    } else {
      AppTheme.showSuccessDialog(
        context,
        "Account has been created successfully",
        onConfirm: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
          );
        },
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
      builder: (context, userVM, child) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: colorScheme.background,
              appBar: AppBar(),
              body: SafeArea(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: height * 0.08),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  widget.isChangePassword
                                      ? "Change Password"
                                      : "Create Password",
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onBackground,
                                  ),
                                ),
                                if (!widget.isChangePassword)
                                  const SizedBox(height: 10),
                                Text(
                                  "Your account has been created!",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onBackground.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.06),
                          if (widget.isChangePassword)
                            BrandedTextField(
                              controller: _oldPasswordController,
                              labelText: "Old Password",
                              isFilled: true,
                              isPassword: true,
                              validator: _oldPasswordValidator,
                            ),
                          if (widget.isChangePassword) const SizedBox(height: 20),
                          BrandedTextField(
                            controller: _passwordController,
                            labelText: "New Password",
                            isFilled: true,
                            isPassword: true,
                            validator: _passwordValidator,
                          ),
                          const SizedBox(height: 20),
                          BrandedTextField(
                            controller: _confirmPasswordController,
                            labelText: "Confirm New Password",
                            isFilled: true,
                            isPassword: true,
                            validator: _confirmPasswordValidator,
                          ),
                          const SizedBox(height: 40),
                          BrandedPrimaryButton(
                            name: "Submit",
                            isEnabled: !userVM.isLoading,
                            onPressed: () => _submitPassword(userVM),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (userVM.isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }
}
