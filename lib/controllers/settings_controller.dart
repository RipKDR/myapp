import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _highContrast = false;
  bool _reduceMotion = false;
  double _textScale = 1; // 1.0=100%, 1.3=130%, etc.
  bool _disableHaptics = false; // New: Control haptic feedback
  bool _voiceNavigation = false;
  bool _cognitiveAssistance = false;
  bool _notifAppointmentReminders = true;
  bool _notifBudgetAlerts = true;
  bool _notifAIUpdates = true;
  bool _shareData = true;
  bool _analyticsEnabled = false;
  bool _crashReportingEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get highContrast => _highContrast;
  bool get reduceMotion => _reduceMotion;
  double get textScale => _textScale.clamp(0.8, 2.0);
  bool get disableHaptics => _disableHaptics;
  bool get voiceNavigation => _voiceNavigation;
  bool get cognitiveAssistance => _cognitiveAssistance;
  bool get notifAppointmentReminders => _notifAppointmentReminders;
  bool get notifBudgetAlerts => _notifBudgetAlerts;
  bool get notifAIUpdates => _notifAIUpdates;
  bool get shareData => _shareData;
  bool get analyticsEnabled => _analyticsEnabled;
  bool get crashReportingEnabled => _crashReportingEnabled;

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
    _disableHaptics = prefs.getBool('disableHaptics') ?? false;
    _voiceNavigation = prefs.getBool('voiceNavigation') ?? false;
    _cognitiveAssistance = prefs.getBool('cognitiveAssistance') ?? false;
    _notifAppointmentReminders =
        prefs.getBool('notifAppointmentReminders') ?? true;
    _notifBudgetAlerts = prefs.getBool('notifBudgetAlerts') ?? true;
    _notifAIUpdates = prefs.getBool('notifAIUpdates') ?? true;
    _shareData = prefs.getBool('shareData') ?? true;
    _analyticsEnabled = prefs.getBool('analyticsEnabled') ?? false;
    _crashReportingEnabled = prefs.getBool('crashReportingEnabled') ?? true;
    notifyListeners();
  }

  Future<void> setThemeMode(final ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  Future<void> setHighContrast(final bool value) async {
    _highContrast = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrast', value);
  }

  Future<void> setReduceMotion(final bool value) async {
    _reduceMotion = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduceMotion', value);
  }

  Future<void> setTextScale(final double value) async {
    _textScale = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScale', value);
  }

  Future<void> setDisableHaptics(final bool value) async {
    _disableHaptics = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disableHaptics', value);
  }

  Future<void> setVoiceNavigation(final bool value) async {
    _voiceNavigation = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voiceNavigation', value);
  }

  Future<void> setCognitiveAssistance(final bool value) async {
    _cognitiveAssistance = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cognitiveAssistance', value);
  }

  Future<void> setNotifAppointmentReminders(final bool value) async {
    _notifAppointmentReminders = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifAppointmentReminders', value);
  }

  Future<void> setNotifBudgetAlerts(final bool value) async {
    _notifBudgetAlerts = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifBudgetAlerts', value);
  }

  Future<void> setNotifAIUpdates(final bool value) async {
    _notifAIUpdates = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifAIUpdates', value);
  }

  Future<void> setShareData(final bool value) async {
    _shareData = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shareData', value);
  }

  Future<void> setAnalyticsEnabled(final bool value) async {
    _analyticsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('analyticsEnabled', value);
  }

  Future<void> setCrashReportingEnabled(final bool value) async {
    _crashReportingEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('crashReportingEnabled', value);
  }
}
