import 'package:cartie/core/utills/constant.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class UserContextData {
  /// Fetch all necessary user-related data
  static Future<void> setCurrentUserAndFetchUserData(
      BuildContext context) async {
    try {
      final userProvider = Provider.of<UserViewModel>(context, listen: false);
      // final mapProvider = Provider.of<MapProvider>(context, listen: false);
      // final tripProvider = Provider.of<TripViewModel>(context, listen: false);
      String userId = SharedPrefUtil.getValue(userIdPref, "") as String;
      String accessToken =
          SharedPrefUtil.getValue(accessTokenPref, "") as String;
      List<Future> lstFutures = <Future>[
        userProvider.getUserProfile(accessToken, userId),
      ];

      await Future.wait(lstFutures);
    } catch (e) {
      debugPrint('User data fetch failed: $e');

      // Optional: Handle logout if needed
      if (e.toString().contains('Token expired') ||
          e.toString().contains('Unauthorized')) {
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => const LoginScreen()),
        //   (route) => false,
        // );
      }
    }
  }
}
