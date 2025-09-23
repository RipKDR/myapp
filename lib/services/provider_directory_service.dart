import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/provider_location.dart';

class ProviderDirectoryService {
  static const _cacheKey = 'provider_cache_v1';

  static Future<List<ProviderLocation>> listProviders() async {
    try {
      // TODO: Replace with Firestore or API fetch; for now load cache or seed
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final list = decoded.cast<Map<String, dynamic>>();
          return list
              .map((final json) {
                try {
                  return ProviderLocation.fromMap(json);
                } catch (e) {
                  // Skip invalid entries
                  return null;
                }
              })
              .where((final provider) => provider != null)
              .cast<ProviderLocation>()
              .toList();
        }
      }

      // Return seed data if cache is empty or invalid
      final seed = [
        ProviderLocation(
            id: 'p1',
            name: 'FlexCare Physio',
            lat: -33.86,
            lng: 151.21,
            waitMinutes: 30,
            accessible: true,
            rating: 4.6),
        ProviderLocation(
            id: 'p2',
            name: 'Ability OT',
            lat: -33.87,
            lng: 151.22,
            waitMinutes: 50,
            accessible: false,
            rating: 4.2),
        ProviderLocation(
            id: 'p3',
            name: 'CareCo Support',
            lat: -33.88,
            lng: 151.20,
            waitMinutes: 70,
            accessible: true,
            rating: 3.9),
      ];
      await saveCache(seed);
      return seed;
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  static Future<void> saveCache(final List<ProviderLocation> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((final e) => e.toMap()).toList();
      await prefs.setString(_cacheKey, jsonEncode(jsonList));
    } catch (e) {
      // Handle save error gracefully
      // Could log to analytics or show user notification
    }
  }
}
