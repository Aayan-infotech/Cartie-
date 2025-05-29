import 'package:cartie/core/api_services/server_calls/dashboard_api.dart';
import 'package:cartie/core/models/carting_rules_model.dart';
import 'package:cartie/core/models/lsv_model.dart';
import 'package:flutter/foundation.dart';

class DashBoardProvider extends ChangeNotifier {
  final DashboardAPIs _dashboardAPIs = DashboardAPIs();

  LSVInfo? _lsvInfo;
  bool _isLoading = false;
  String? _error;

  LSVInfo? get lsvInfo => _lsvInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String seftyVideoUrl = '';
  CartingRules? _cartingRules;
  bool _isCartingLoading = false;
  String? _cartingError;
  String _selectedQuestionTab = 'cartingRule';

  // Add these getters
  CartingRules? get cartingRules => _cartingRules;
  bool get isCartingLoading => _isCartingLoading;
  String? get cartingError => _cartingError;
  String get selectedQuestionTab => _selectedQuestionTab;

  Future<void> fetchCartingRules() async {
    _isCartingLoading = true;
    notifyListeners();

    try {
      final response = await _dashboardAPIs.getCartingRules();
      if (response.success) {
        _cartingRules = CartingRules.fromJson(response.data['data']);
        _cartingError = null;
      } else {
        _cartingError = response.message ?? 'Failed to load carting rules';
      }
    } catch (e) {
      _cartingError = 'An error occurred: $e';
    } finally {
      _isCartingLoading = false;
      notifyListeners();
    }
  }

  void selectQuestionTab(String tab) {
    _selectedQuestionTab = tab;
    notifyListeners();
  }

  Future<void> fetchLSVData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dashboardAPIs.getLsv();
      if (response.success) {
        _lsvInfo = LSVInfo.fromJson(response.data['data']);
        _error = null;
      } else {
        _error = response.message ?? 'Failed to load LSV data';
      }
    } catch (e) {
      _error = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getSeftyVideo() async {
    // _isLoading = true;
    // notifyListeners();

    try {
      final response = await _dashboardAPIs.getSeftyVideo();
      if (response.success) {
        var data = response.data['data'][0];
        seftyVideoUrl = data['url'];
      } else {
        seftyVideoUrl = '';
        _error = response.message ?? 'Failed to load LSV data';
      }
    } catch (e) {
      _error = 'An error occurred: $e';
    } finally {
      // _isLoading = false;
      // notifyListeners();
    }
  }
}
