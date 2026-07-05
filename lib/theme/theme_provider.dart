import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme;

  ThemeProvider() : _currentTheme = AppTheme.fromMode(AppThemeMode.dark);

  AppTheme get currentTheme => _currentTheme;
  AppThemeMode get mode => _currentTheme.mode;
  ThemeData get themeData => _currentTheme.data;
  Color get primaryColor => _currentTheme.primaryColor;
  Color get surfaceColor => _currentTheme.surfaceColor;
  Color get backgroundColor => _currentTheme.backgroundColor;
  Color get textColor => _currentTheme.textColor;
  Color? get readerBackground => _currentTheme.readerBackground;
  Color? get readerText => _currentTheme.readerText;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // If user hasn't explicitly set a theme, default to dark
    final modeIndex = prefs.getInt('theme_mode') ?? AppThemeMode.dark.index;
    final mode = AppThemeMode.values[modeIndex];
    _currentTheme = AppTheme.fromMode(mode);
    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _currentTheme = AppTheme.fromMode(mode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  Future<void> setCustomTheme(Color primary, Color background) async {
    _currentTheme = AppTheme.fromMode(AppThemeMode.custom,
        customPrimary: primary, customBackground: background);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', AppThemeMode.custom.index);
  }
}
