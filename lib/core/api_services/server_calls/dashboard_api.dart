import 'package:cartie/core/api_services/api_base.dart';
import 'package:cartie/core/api_services/call_helper.dart';
import 'package:cartie/core/utills/constant.dart';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utills/shared_pref_util.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardAPIs {
  DashboardAPIs() : super();

  Future<ApiResponseWithData<Map<String, dynamic>>> getLsv() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData(
      'api/user/lsv/getGLSV',
      data,
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getCartingRules() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData(
      'api/user/lsv/getRRLSV',
      data,
    );
  }

  Future<ApiResponseWithData<Map<String, dynamic>>> getSeftyVideo() async {
    Map<String, String> data = {};

    return await CallHelper().getWithData(
      'api/user/video/getSafetyVideos',
      data,
    );
  }
}
