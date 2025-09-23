enum FeatureTier { free, premium }

class FeatureFlags {
  static bool isPremiumEnabled =
      const bool.fromEnvironment('PREMIUM_ENABLED');
  static bool isMapsEnabled =
      const String.fromEnvironment('GOOGLE_MAPS_ENABLED', defaultValue: 'true') ==
          'true';

  static bool allow(final FeatureTier tier) {
    if (tier == FeatureTier.free) return true;
    return isPremiumEnabled;
  }
}
