import 'package:cartie/core/utills/branded_primary_button.dart';
import 'package:cartie/features/login_signup_flow/login_screen.dart';
import 'package:cartie/features/login_signup_flow/sign_up_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const Spacer(),
              Center(child: Image.asset("assets/images/logo.png")),
              SizedBox(
                height: 10,
              ),
              Text(
                "Title of the Product here",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20),
              ),
              SizedBox(
                height: 5,
              ),
              Text("Maybe some tagline here"),
              const Spacer(),
              BrandedPrimaryButton(
                isEnabled: true,
                name: "Login",
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return LoginScreen();
                  }));
                },
              ),
              const SizedBox(height: 20),
              BrandedPrimaryButton(
                isUnfocus: true,
                isEnabled: true,
                name: "Sign Up",
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return SignUpScreen();
                  }));
                },
              ),
              const SizedBox(height: 30), // bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
