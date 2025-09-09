enum FeatureTier { free, premium }

class FeatureFlags {
  static bool isPremiumEnabled = false; // Toggle for dev/demo
  static bool isMapsEnabled =
      String.fromEnvironment('GOOGLE_MAPS_ENABLED', defaultValue: 'false') ==
          'true';

  static bool allow(FeatureTier tier) {
    if (tier == FeatureTier.free) return true;
    return isPremiumEnabled;
  }
}
