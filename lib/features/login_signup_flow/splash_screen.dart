import 'package:cartie/core/utills/constant.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';
import 'package:cartie/core/utills/user_context_data.dart';
import 'package:cartie/features/dashboard/dashboard_screen.dart';
import 'package:cartie/features/login_signup_flow/login_screen.dart';
import 'package:cartie/features/login_signup_flow/welcome_screen.dart';
import 'package:flutter/material.dart';

import '../../core/theme/theme_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _navigateToAppropriateScreen();
  }

  void _navigateToAppropriateScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    // final themeProvider = ThemeProvider();// Ensure async bindings are available
    // await themeProvider.init();
    final isLoggedIn = SharedPrefUtil.getValue(isLoginPref, false) as bool;
    if (isLoggedIn) {
      await UserContextData.setCurrentUserAndFetchUserData(context);
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        _createFadeRoute(
          destination:
              isLoggedIn ? const DashboardScreen() : const LoginScreen(),
        ),
      );
    }
  }

  Route _createFadeRoute({required Widget destination}) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset("assets/images/logo.png"),
      ),
    );
  }
}
