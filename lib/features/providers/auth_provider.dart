import 'dart:convert';

import 'package:cartie/core/api_services/call_helper.dart';
import 'package:cartie/core/api_services/server_calls/auth_api.dart';
import 'package:cartie/core/models/user_model.dart';
import 'package:cartie/core/utills/constant.dart';
import 'package:cartie/core/utills/pdf_api.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserViewModel extends ChangeNotifier {
  final AuthAPIs _authAPIs = AuthAPIs();

  bool isLoading = false;
  String errorMessage = '';
  UserModel user = UserModel(
  image: '',
      name: "Jhon",
      email: 'Jhon@gmail.com',
      mobile: "123456789",
      address: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      refreshToken: '');

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void clearErrorMessage() {
    errorMessage = '';
    notifyListeners();
  }

  Future<ApiResponseWithData> login(String email, String password) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      final response = await _authAPIs.login(email, password);
      if (response.success) {
      } else {
        errorMessage = response.message ?? 'Login failed';
      }
      return response;
    } catch (e) {
      errorMessage = e.toString();
      _setLoading(false);
      rethrow; // or return an error response if you prefer
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponseWithData> signUp(
      String name, String mobile, String state, String email) async {
    _setLoading(true);
    clearErrorMessage();
    late ApiResponseWithData response;

    try {
      response = await _authAPIs.signUp(name, mobile, state, email);
      if (!response.success) {
        errorMessage = response.message;
      }
    } catch (e) {
      errorMessage = e.toString();
      _setLoading(false);
      rethrow;
    } finally {
      _setLoading(false);
    }

    return response;
  }

  Future<ApiResponse> forgotPassword(String email) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      final response = await _authAPIs.forgetPassword(email);
      if (!response.success) {
        errorMessage = response.message;
      }
      return response;
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponse(errorMessage, false);
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponseWithData> updateProfile(
    String name,
    String state,
  ) async {
    _setLoading(true);
    clearErrorMessage();

    try {
      final response = await _authAPIs.updateProfile(name, state);
      if (!response.success) {
        errorMessage = response.message ?? 'Update failed';
      }
      return response; // ✅ Return the response here
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponseWithData(
          errorMessage, false); // ✅ Return failure response on error
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponseWithData> addLocation(String name, LatLng latLng) async {
    _setLoading(true);
    clearErrorMessage();

    late final ApiResponseWithData response;

    try {
      response = await _authAPIs.saveLocation(name, latLng);
      if (!response.success) {
        errorMessage = response.message ?? 'Update failed';
      }
    } catch (e) {
      errorMessage = e.toString();
      rethrow; // optionally propagate the error
    } finally {
      _setLoading(false);
    }

    return response;
  }

  Future<void> getUserProfile(String token, String id,
      {bool forceRefresh = false}) async {
    _setLoading(true);
    clearErrorMessage();

    // final startTime = DateTime.now(); // Start timing
    // final bool isFileHas =
    //     await PDFApi.checkIfFileExists(userProfileLocalFilePath);
    // print(isFileHas);

    try {
      if (true) {
        final response = await _authAPIs.getUserById(token, id);
        if (!response.success) {
          errorMessage = response.message ?? 'Fetch failed';
        } else {
          final jsonData = response.data['data'];
          user = UserModel.fromJson(jsonData);
          print(user);
          notifyListeners();
          // Save to local storage
          // var json = jsonEncode(jsonData);
          // print(json);
          // await PDFApi.saveFileToLocalDirectory(userProfileLocalFilePath, json);

          // final endTime = DateTime.now();
          // print(
          //     'Fetched from server in ${endTime.difference(startTime).inMilliseconds} ms');
        }
      } else {
        // Load from local storage
        // final localJson =
        //     await PDFApi.readFileFromLocalDirectory(userProfileLocalFilePath);
        // user = UserModel.fromJson(jsonDecode(localJson));

        // final endTime = DateTime.now();
        // print(
        //     'Loaded from local in ${endTime.difference(startTime).inMilliseconds} ms');
        // print("object");
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshToken(String token) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      final response = await _authAPIs.refresh(token);
      if (!response.success) {
        errorMessage = response.message ?? 'Refresh token failed';
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponseWithData> verifyOtp(String email, String otp) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      final response = await _authAPIs.verifyOTP(email, otp);
      if (!response.success) {
        errorMessage = response.message ?? 'OTP verification failed';
      }
      return response;
    } catch (e) {
      errorMessage = e.toString();
      return ApiResponseWithData(null, false, message: errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendOtp(String email, String otp) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      final response = await _authAPIs.resendOtp(email, otp);
      if (!response.success) {
        errorMessage = response.message ?? 'OTP resend failed';
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiResponse> setPassword(String email, String password) async {
    _setLoading(true);
    clearErrorMessage();
    late ApiResponse response;
    try {
      response = await _authAPIs.setPassword(email, password);
      if (!response.success) {
        errorMessage = response.message ?? 'Set password failed';
      }
    } catch (e) {
      errorMessage = e.toString();
      response = ApiResponse(errorMessage, false); // fallback response
    } finally {
      _setLoading(false);
    }

    return response;
  }

  Future<void> changePassword(
      String oldPassword, String newPassword, String password) async {
    _setLoading(true);
    clearErrorMessage();
    try {
      final response =
          await _authAPIs.changePassword(oldPassword, newPassword, password);
      if (!response.success) {
        errorMessage = response.message ?? 'Set password failed';
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    clearErrorMessage();
    try {
      final response = await _authAPIs.logout();
      if (!response.success) {
        errorMessage = response.message ?? 'Logout failed';
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
}
