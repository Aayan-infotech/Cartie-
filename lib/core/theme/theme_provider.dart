import 'package:flutter/material.dart';
import '../utills/constant.dart';
import '../utills/shared_pref_util.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // ✅ Default: system theme

  ThemeMode get themeMode => _themeMode;

  /// Set and save theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    SharedPrefUtil.setValue(theme, mode.toString().split('.').last);
  }

  /// Load saved theme mode from preferences
  Future<void> init() async {
    final String? savedTheme =
        await SharedPrefUtil.getValue(theme, '') as String?;

    if (savedTheme != null && savedTheme.isNotEmpty) {
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
          _themeMode = ThemeMode.system;
          break;
        default:
          _themeMode = ThemeMode.system; // fallback
          break;
      }
    } else {
      _themeMode = ThemeMode.system; // ✅ no saved theme → system
    }

    notifyListeners();
  }
}
