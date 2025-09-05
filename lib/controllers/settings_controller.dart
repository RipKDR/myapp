import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _highContrast = false;
  bool _reduceMotion = false;
  double _textScale = 1.0; // 1.0=100%, 1.3=130%, etc.

  ThemeMode get themeMode => _themeMode;
  bool get highContrast => _highContrast;
  bool get reduceMotion => _reduceMotion;
  double get textScale => _textScale.clamp(0.8, 2.0);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('themeMode');
    _themeMode = switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _highContrast = prefs.getBool('highContrast') ?? false;
    _reduceMotion = prefs.getBool('reduceMotion') ?? false;
    _textScale = prefs.getDouble('textScale') ?? 1.0;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrast', value);
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduceMotion', value);
  }

  Future<void> setTextScale(double value) async {
    _textScale = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScale', value);
  }
}

