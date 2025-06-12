import 'package:cartie/core/api_services/api_base.dart';
import 'package:cartie/core/api_services/call_helper.dart';
import 'package:cartie/core/utills/constant.dart';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utills/shared_pref_util.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthAPIs {
  AuthAPIs() : super();

  Future<ApiResponseWithData<Map<String, dynamic>>> login(
      String email, String password) async {
    Map<String, String> data = {
      'email': email,
      'password': password,
    };

    return await CallHelper().postWithData('api/users/login', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> saveLocation(
      String name, LatLng latLng) async {
    Map<String, String> data = {
      "name": name,
      "latitude": latLng.longitude.toString(),
      "longitude": latLng.latitude.toString()
    };

    return await CallHelper()
        .postWithData('api/user/location/addLocation', data, {});
  }

  Future<ApiResponseWithData> updateProfile(
    String name,
    String state,
  ) async {
    Map<String, String> data = {
      "name": name,
      //"address": state,
    };
    String userId = SharedPrefUtil.getValue(userIdPref, "") as String;

    return await CallHelper()
        .putWithData('api/users/updateProfile/${userId}', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> signUp(
      String name, String mobileNumber, String state, String email) async {
    Map<String, String> data = {
      "name": name,
      "mobile": mobileNumber,
      "email": email,
      "address": state
    };
    return await CallHelper().postWithData('api/users/signup', data, {});
  }

  //
  Future<ApiResponse> refresh(String refreshToken) async {
    Map<String, String> data = {
      'refreshToken': refreshToken,
    };
    return await CallHelper().post('api/users/refreshToken', data);
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> verifyOTP(
      String email, String otp) async {
    Map<String, String> data = {
      'email': email,
      'otp': otp,
    };
    return await CallHelper().postWithData('api/users/verifyOTP', data, {});
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> resendOtp(
      String email, String otp) async {
    Map<String, String> data = {
      'email': email,
      'otp': otp,
    };
    return await CallHelper().postWithData('api/users/resend-otp', data, {});
  }

  Future<ApiResponse> setPassword(String email, String password) async {
    Map<String, String> data = {
      "email": email,
      "password": password,
    };
    return await CallHelper().post(
      'api/users/set-password',
      data,
    );
  }

  Future<ApiResponse> passwordReset(String token, String password) async {
    Map<String, String> data = {
      'newPassword': password,
      'token': token,
    };

    return await CallHelper().post('auth/reset-password', data);
  }

  Future<ApiResponse> logout() async {
    String refToken = SharedPrefUtil.getValue(refreshTokenPref, "") as String;

    Map<String, String> data = {
      'refreshToken': refToken,
    };

    var res = await CallHelper().post(
      'auth/logout',
      data,
    );
    return res;
  }

  Future<ApiResponse> forgetPassword(String email) async {
    Map<String, String> data = {
      'email': email,
    };

    return await CallHelper().post('api/users/forgot-password', data);
  }

  Future<ApiResponse> changePassword(
      String oldPassword, String newPassword, String confirmNewPassword) async {
    Map<String, String> data = {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
      "confirmNewPassword": confirmNewPassword,
    };
    return await CallHelper().post(
      'api/users/changePassword',
      data,
    );
  }

  Future<ApiResponseWithData> deleteAccount() async {
    var userId = SharedPrefUtil.getValue(userIdPref, "") as String;
    Map<String, dynamic> data = {"status": 0};
    return await CallHelper().putWithData(
      "update-user-status-admin/$userId/status",
      data,
      {},
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getNotifications() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData(
      'notifications',
      data,
    );
  }

  Future<ApiResponseWithData> getUserById(String token, String id) async {
    // replace with your actual base URL
    final String url = '${CallHelper.baseUrl}api/users/getProfile/$id';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Optional: use if auth is required
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponseWithData(data, true, message: "");
      } else {
        throw Exception('Failed to fetch user. Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponseWithData<Map<String, dynamic>>>
      getSubscriptionDetails() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData('users/user-subscription', data);
  }
}
