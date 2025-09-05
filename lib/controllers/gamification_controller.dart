import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamificationController extends ChangeNotifier {
  int _points = 0;
  int _streakDays = 0;
  Set<String> _badges = {};
  String? _lastBadge;

  int get points => _points;
  int get streakDays => _streakDays;
  Set<String> get badges => _badges;
  String? get lastBadge => _lastBadge;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _points = p.getInt('points') ?? 0;
    _streakDays = p.getInt('streakDays') ?? 0;
    _badges = (p.getStringList('badges') ?? []).toSet();
    notifyListeners();
  }

  Future<void> addPoints(int value) async {
    _points += value;
    await _evaluate();
  }

  Future<void> bumpStreak() async {
    _streakDays += 1;
    await _save();
  }

  Future<void> grantBadge(String badge) async {
    if (_badges.add(badge)) {
      _lastBadge = badge;
      await _save();
    }
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('points', _points);
    await p.setInt('streakDays', _streakDays);
    await p.setStringList('badges', _badges.toList());
    notifyListeners();
  }

  Future<void> _evaluate() async {
    // Award badges at thresholds
    if (_points >= 50 && !_badges.contains('Smart Spender')) {
      await grantBadge('Smart Spender');
    }
    if (_points >= 100 && !_badges.contains('NDIS Champion')) {
      await grantBadge('NDIS Champion');
    }
    await _save();
  }

  void clearLastBadge() {
    _lastBadge = null;
  }
}
