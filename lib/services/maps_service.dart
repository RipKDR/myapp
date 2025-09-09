import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/provider_location.dart';

/// Google Maps helper service with offline caching capabilities
class MapsService {
  static const String _offlineCacheKey = 'maps_offline_cache';
  static const String _providersCacheKey = 'maps_providers_cache';

  /// Preload offline data including providers and map tiles metadata
  Future<void> preloadOfflineData() async {
    try {
      // Cache providers data for offline use
      await _cacheProvidersData();

      // Cache map tiles metadata
      await _cacheMapTilesMetadata();

      // Cache user location if available
      await _cacheUserLocation();
    } catch (e) {
      // Handle preload errors gracefully
      // Could log to analytics
    }
  }

  /// Cache providers data for offline access
  Future<void> _cacheProvidersData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final providers = await _getProvidersData();

      if (providers.isNotEmpty) {
        final jsonData = providers.map((p) => p.toMap()).toList();
        await prefs.setString(_providersCacheKey, jsonEncode(jsonData));
      }
    } catch (e) {
      // Handle caching error
    }
  }

  /// Get providers data (placeholder implementation)
  Future<List<ProviderLocation>> _getProvidersData() async {
    // This would typically fetch from a real API
    return [];
  }

  /// Cache map tiles metadata
  Future<void> _cacheMapTilesMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = {
        'last_updated': DateTime.now().toIso8601String(),
        'cached_tiles': <String>[],
        'zoom_levels': [10, 12, 14, 16],
      };

      await prefs.setString(_offlineCacheKey, jsonEncode(metadata));
    } catch (e) {
      // Handle caching error
    }
  }

  /// Cache user location for offline use
  Future<void> _cacheUserLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // This would get actual user location
      final location = {
        'latitude': -33.8688,
        'longitude': 151.2093,
        'last_updated': DateTime.now().toIso8601String(),
      };

      await prefs.setString('user_location_cache', jsonEncode(location));
    } catch (e) {
      // Handle caching error
    }
  }

  /// Get cached providers data
  Future<List<ProviderLocation>> getCachedProviders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_providersCacheKey);

      if (cachedData != null) {
        final decoded = jsonDecode(cachedData);
        if (decoded is List) {
          return decoded.map((json) => ProviderLocation.fromMap(json)).toList();
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Check if offline data is available
  Future<bool> hasOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_offlineCacheKey) &&
          prefs.containsKey(_providersCacheKey);
    } catch (e) {
      return false;
    }
  }

  /// Clear offline cache
  Future<void> clearOfflineCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_offlineCacheKey);
      await prefs.remove(_providersCacheKey);
      await prefs.remove('user_location_cache');
    } catch (e) {
      // Handle clear error
    }
  }
}
