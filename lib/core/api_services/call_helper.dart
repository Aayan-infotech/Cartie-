import 'dart:async';
import 'dart:convert';

import 'package:cartie/core/utills/constant.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';
import 'package:cartie/features/login_signup_flow/login_screen.dart';
import 'package:cartie/main.dart';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: timeoutInSeconds),
      receiveTimeout: Duration(seconds: timeoutInSeconds),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ),
  );

  CallHelper() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = SharedPrefUtil.getValue(accessTokenPref, "") as String;
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioError e, handler) async {
        if (e.response?.statusCode == 401) {
          final success = await _refreshToken();
          if (success) {
            final token =
                SharedPrefUtil.getValue(accessTokenPref, "") as String;
            e.requestOptions.headers['Authorization'] = 'Bearer $token';
            final retryResponse = await _dio.fetch(e.requestOptions);
            return handler.resolve(retryResponse);
          } else {
            return handler.reject(e);
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<ApiResponse> get(String urlSuffix,
      {Map<String, dynamic>? queryParams}) async {
    return _performRequest(() async {
      final response = await _dio.get(urlSuffix, queryParameters: queryParams);
      return _processResponse(response);
    });
  }

  Future<ApiResponseWithData<T>> getWithData<T>(String urlSuffix, T defaultData,
      {Map<String, dynamic>? queryParams}) async {
    return _performRequest(() async {
      final response = await _dio.get(urlSuffix, queryParameters: queryParams);
      return _processResponseWithData(response, defaultData);
    });
  }

  Future<ApiResponse> post(String urlSuffix, Map<String, dynamic> body) async {
    return _performRequest(() async {
      final response = await _dio.post(urlSuffix, data: body);
      return _processResponse(response);
    });
  }

  Future<ApiResponseWithData<T>> postWithData<T>(
      String urlSuffix, Map<String, dynamic> body, T defaultData) async {
    return _performRequest(() async {
      final response = await _dio.post(urlSuffix, data: body);
      return _processResponseWithData(response, defaultData);
    });
  }

  Future<ApiResponseWithData<T>> putWithData<T>(
      String urlSuffix, Map<String, dynamic> body, T defaultData) async {
    return _performRequest(() async {
      final response = await _dio.put(urlSuffix, data: body);
      return _processResponseWithData(response, defaultData);
    });
  }

  Future<ApiResponse> delete(String urlSuffix,
      {Map<String, dynamic>? queryParams}) async {
    return _performRequest(() async {
      final response =
          await _dio.delete(urlSuffix, queryParameters: queryParams);
      return _processResponse(response);
    });
  }

  Future<ApiResponse> deleteWithBody(
      String urlSuffix, Map<String, dynamic> body) async {
    return _performRequest(() async {
      final response = await _dio.delete(urlSuffix, data: body);
      return _processResponse(response);
    });
  }

  Future<ApiResponse> patch(String urlSuffix, Map<String, dynamic> body) async {
    return _performRequest(() async {
      final response = await _dio.patch(urlSuffix, data: body);
      return _processResponse(response);
    });
  }

  ApiResponse _processResponse(Response response) {
    final data = response.data;
    String message =
        (data["message"] is List ? data["message"][0] : data["message"]) ??
            internalServerErrorMessage;

    return (response.statusCode == 200 || response.statusCode == 201)
        ? ApiResponse(message, true)
        : ApiResponse(message, false);
  }

  ApiResponseWithData<T> _processResponseWithData<T>(
      Response response, T defaultData) {
    final data = response.data;
    String message =
        (data["message"] is List ? data["message"][0] : data["message"]) ??
            internalServerErrorMessage;

    return (response.statusCode == 200 || response.statusCode == 201)
        ? ApiResponseWithData(data as T, true)
        : ApiResponseWithData(defaultData, false, message: message);
  }

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

      final response = await _dio
          .post("api/users/refreshToken", data: {"refreshToken": refreshToken});

      if (response.statusCode == 200) {
        final data = response.data;
        String newAccessToken = data["accessToken"] ?? "";
        await SharedPrefUtil.setValue(accessTokenPref, newAccessToken);
        _refreshCompleter?.complete();
        _isRefreshing = false;
        return true;
      } else {
        _navigateToLogin();
      }
    } catch (_) {
      _navigateToLogin();
    }

    _refreshCompleter?.complete();
    _isRefreshing = false;
    return false;
  }

  void _navigateToLogin() {
    Future.microtask(() {
      SharedPrefUtil.logOut();
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    });
  }

  Future<T> _performRequest<T>(Future<T> Function() requestFunction) async {
    try {
      return await requestFunction();
    } on DioError catch (_) {
      if (T == ApiResponseWithData<Map<String, dynamic>>) {
        return ApiResponseWithData<Map<String, dynamic>>({}, false,
            message: "Request failed") as T;
      } else if (T == ApiResponseWithData<String>) {
        return ApiResponseWithData<String>("Request failed", false,
            message: "Request failed") as T;
      } else if (T == ApiResponse) {
        return ApiResponse("Request failed", false) as T;
      } else {
        rethrow;
      }
    }
  }
}
