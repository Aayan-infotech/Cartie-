import 'dart:async';
import 'dart:convert';

import 'package:cartie/core/utills/constant.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';
import 'package:cartie/features/login_signup_flow/login_screen.dart';
import 'package:cartie/main.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiResponse {
  final String message;
  final bool success;

  ApiResponse(this.message, this.success);
}

class ApiResponseWithData<T> {
  final T data;
  final bool success;
  final String message;

  ApiResponseWithData(this.data, this.success, {this.message = "none"});
}

class CallHelper {
  static const String baseUrl = "http://44.217.145.210:9090/";
  static const int timeoutInSeconds = 20;
  static const String internalServerErrorMessage = "Internal server error.";
  static bool _isRefreshing = false;
  static Completer<void>? _refreshCompleter;

  Future<Map<String, String>> getHeaders() async {
    String accessToken = SharedPrefUtil.getValue(accessTokenPref, "") as String;
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  Future<ApiResponse> get(String urlSuffix,
      {Map<String, dynamic>? queryParams}) async {
    return _performRequest(() async {
      Uri uri =
          Uri.parse('$baseUrl$urlSuffix').replace(queryParameters: queryParams);
      final response = await http
          .get(uri, headers: await getHeaders())
          .timeout(const Duration(seconds: timeoutInSeconds));
      return _processResponse(
          response, () => get(urlSuffix, queryParams: queryParams));
    });
  }

  Future<ApiResponseWithData<T>> getWithData<T>(String urlSuffix, T defaultData,
      {Map<String, dynamic>? queryParams}) async {
    return _performRequest(() async {
      Uri uri =
          Uri.parse('$baseUrl$urlSuffix').replace(queryParameters: queryParams);
      var headder = await getHeaders();
      debugPrint("URL => $uri and HEADER => ${headder}");
      final response = await http
          .get(uri, headers: await getHeaders())
          .timeout(const Duration(seconds: timeoutInSeconds));
      return _processResponseWithData(response, defaultData,
          () => getWithData(urlSuffix, defaultData, queryParams: queryParams));
    });
  }

  Future<ApiResponse> delete(String urlSuffix,
      {Map<String, dynamic>? queryParams}) async {
    return _performRequest(() async {
      Uri uri =
          Uri.parse('$baseUrl$urlSuffix').replace(queryParameters: queryParams);
      final response = await http
          .delete(
            uri,
            headers: await getHeaders(),
          )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return _processResponse(
          response, () => delete(urlSuffix, queryParams: queryParams));
    });
  }

  Future<ApiResponse> post(String urlSuffix, Map<String, dynamic> body) async {
    return _performRequest(() async {
      final response = await http
          .post(
            Uri.parse('$baseUrl$urlSuffix'),
            headers: await getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return _processResponse(response, () => post(urlSuffix, body));
    });
  }

  Future<ApiResponseWithData<T>> postWithData<T>(
      String urlSuffix, Map<String, dynamic> body, T defaultData) async {
    return _performRequest(() async {
      final response = await http
          .post(
            Uri.parse('$baseUrl$urlSuffix'),
            headers: await getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return _processResponseWithData(response, defaultData,
          () => postWithData(urlSuffix, body, defaultData));
    });
  }

  Future<ApiResponseWithData<T>> putWithData<T>(
      String urlSuffix, Map<String, dynamic> body, T defaultData) async {
    return _performRequest(() async {
      Uri uri = Uri.parse('$baseUrl$urlSuffix');
      var headder = await getHeaders();
      debugPrint("URL => $uri and HEADER => ${headder}");
      final response = await http
          .put(
            Uri.parse('$baseUrl$urlSuffix'),
            headers: await getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return _processResponseWithData(response, defaultData,
          () => putWithData(urlSuffix, body, defaultData));
    });
  }

  Future<ApiResponse> deleteWithBody(
      String urlSuffix, Map<String, dynamic> body) async {
    return _performRequest(() async {
      Uri uri = Uri.parse('$baseUrl$urlSuffix');
      final response = await http
          .delete(
            uri,
            headers: await getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return _processResponse(response, () => deleteWithBody(urlSuffix, body));
    });
  }

  Future<ApiResponse> patch<T>(
    String urlSuffix,
    Map<String, dynamic> body,
  ) async {
    return _performRequest(() async {
      final response = await http
          .patch(
            Uri.parse('$baseUrl$urlSuffix'),
            headers: await getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return _processResponse(
          response,
          () => patch(
                urlSuffix,
                body,
              ));
    });
  }

  /// Handles API responses and retries if unauthorized (401).
  ApiResponse _processResponse(
      http.Response response, Future<ApiResponse> Function() retryRequest) {
    if (response.statusCode == 401) {
      return _handleUnauthorizedRequest(retryRequest);
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    String message = data["message"][0] ?? internalServerErrorMessage;

    return response.statusCode == 200 || response.statusCode == 201
        ? ApiResponse(data['message'][0] ?? internalServerErrorMessage, true)
        : ApiResponse(message, false);
  }

  ApiResponseWithData<T> _processResponseWithData<T>(http.Response response,
      T defaultData, Future<ApiResponseWithData<T>> Function() retryRequest) {
    if (response.statusCode == 401) {
      return _handleUnauthorizedRequestWithData(defaultData, retryRequest);
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    String message = data["message"][0] ?? internalServerErrorMessage;

    return response.statusCode == 200 || response.statusCode == 201
        ? ApiResponseWithData(data as T, true)
        : ApiResponseWithData(defaultData, false, message: message);
  }

  /// Handles token refresh and retries the failed request.
  _handleUnauthorizedRequest(Future<ApiResponse> Function() retryRequest) {
    return _refreshToken().then((success) async {
      if (success) return await retryRequest();
      return ApiResponse("Session expired. Please log in again.", false);
    }).catchError((_) => ApiResponse("Token refresh failed", false));
  }

  _handleUnauthorizedRequestWithData<T>(
      T defaultData, Future<ApiResponseWithData<T>> Function() retryRequest) {
    return _refreshToken().then((success) async {
      if (success) return await retryRequest();
      return ApiResponseWithData(defaultData, false,
          message: "Session expired. Please log in again.");
    }).catchError((_) => ApiResponseWithData(defaultData, false,
        message: "Token refresh failed"));
  }

  /// Refreshes the token and updates stored credentials.
  // Future<bool> _refreshToken() async {
  //   if (_isRefreshing) {
  //     await _refreshCompleter?.future;
  //     return (SharedPrefUtil.getValue(accessTokenPref, "") as String)
  //         .isNotEmpty;
  //   }

  //   _isRefreshing = true;
  //   _refreshCompleter = Completer<void>();

  //   try {
  //     String refreshToken =
  //         SharedPrefUtil.getValue(refreshTokenPref, "") as String;
  //     final response = await http.post(
  //       Uri.parse("${baseUrl}api/users/refreshToken"),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({"refreshToken": refreshToken}),
  //     );

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = jsonDecode(response.body);
  //       String newAccessToken = data["accessToken"] ?? "";
  //       await SharedPrefUtil.setValue(accessTokenPref, newAccessToken);
  //       _refreshCompleter?.complete();
  //       _isRefreshing = false;
  //       return true;
  //     } else {
  //       navigatorKey.currentState?.pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (_) => const LoginScreen()),
  //         (route) => false, // removes all previous routes
  //       );
  //     }
  //   } catch (_) {
  //     navigatorKey.currentState?.pushAndRemoveUntil(
  //       MaterialPageRoute(builder: (_) => const LoginScreen()),
  //       (route) => false, // removes all previous routes
  //     );
  //   }

  //   _refreshCompleter?.complete();
  //   _isRefreshing = false;
  //   return false;
  // }
  Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      await _refreshCompleter?.future;
      return (SharedPrefUtil.getValue(accessTokenPref, "") as String)
          .isNotEmpty;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      String refreshToken =
          SharedPrefUtil.getValue(refreshTokenPref, "") as String;

      final response = await http.post(
        Uri.parse("${baseUrl}api/users/refreshToken"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        String newAccessToken = data["accessToken"] ?? "";

        await SharedPrefUtil.setValue(accessTokenPref, newAccessToken);
        _refreshCompleter?.complete();
        _isRefreshing = false;
        return true;
      } else {
        _refreshCompleter?.complete();
        _isRefreshing = false;

        // Immediate navigation to Login screen
        Future.microtask(() {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        });

        return false;
      }
    } catch (_) {
      _refreshCompleter?.complete();
      _isRefreshing = false;

      // Immediate navigation to Login screen
      Future.microtask(() {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });

      // Handle any error silently
    }

    // If we reach here, refresh failed
    _refreshCompleter?.complete();
    _isRefreshing = false;

    // // Immediate navigation to Login screen
    // Future.microtask(() {
    //   navigatorKey.currentState?.pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (_) => const LoginScreen()),
    //     (route) => false,
    //   );
    // });

    return false;
  }

  /// Wraps API calls with exception handling and retry logic.
  Future<T> _performRequest<T>(Future<T> Function() requestFunction) async {
    try {
      return await requestFunction();
    } catch (e) {
      if (T == ApiResponseWithData<Map<String, dynamic>>) {
        return ApiResponseWithData<Map<String, dynamic>>({}, false,
            message: "Request failed") as T;
      } else if (T == ApiResponseWithData<String>) {
        return ApiResponseWithData<String>("Request failed", false,
            message: "Request failed") as T;
      } else if (T == ApiResponse) {
        return ApiResponse("Request failed", false) as T;
      } else {
        throw Exception("Unexpected return type in _performRequest: $T");
      }
    }
  }
}
