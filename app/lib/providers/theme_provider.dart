import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';
import '../config/app_constants.dart';

/// Manages dark/light theme with persistent storage.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  /// Load saved theme preference
  Future<void> _loadTheme() async {
    _isDarkMode = await SecureStorageService.readBool('isDark', defaultValue: false);
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await SecureStorageService.writeBool('isDark', _isDarkMode);
  }

  /// Set specific theme mode
  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    await SecureStorageService.writeBool('isDark', isDark);
  }
}
