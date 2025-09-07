enum FeatureTier { free, premium, enterprise }

class FeatureFlags {
  static bool isPremiumEnabled = true; // Phase 2 features enabled
  static bool isEnterpriseEnabled = true; // Advanced features enabled

  // Phase 2 Feature Flags
  static bool aiChatEnabled = true;
  static bool advancedAnalyticsEnabled = true;
  static bool enhancedGamificationEnabled = true;
  static bool advancedCachingEnabled = true;
  static bool voiceControlEnabled = true;
  static bool predictiveAnalyticsEnabled = true;
  static bool socialFeaturesEnabled = true;
  static bool performanceOptimizationEnabled = true;

  static bool allow(FeatureTier tier) {
    switch (tier) {
      case FeatureTier.free:
        return true;
      case FeatureTier.premium:
        return isPremiumEnabled;
      case FeatureTier.enterprise:
        return isEnterpriseEnabled;
    }
  }

  /// Check if a specific Phase 2 feature is enabled
  static bool isFeatureEnabled(String feature) {
    switch (feature) {
      case 'ai_chat':
        return aiChatEnabled && isPremiumEnabled;
      case 'advanced_analytics':
        return advancedAnalyticsEnabled && isPremiumEnabled;
      case 'enhanced_gamification':
        return enhancedGamificationEnabled && isPremiumEnabled;
      case 'advanced_caching':
        return advancedCachingEnabled && isPremiumEnabled;
      case 'voice_control':
        return voiceControlEnabled && isPremiumEnabled;
      case 'predictive_analytics':
        return predictiveAnalyticsEnabled && isEnterpriseEnabled;
      case 'social_features':
        return socialFeaturesEnabled && isPremiumEnabled;
      case 'performance_optimization':
        return performanceOptimizationEnabled && isPremiumEnabled;
      default:
        return false;
    }
  }

  /// Get all enabled features
  static List<String> getEnabledFeatures() {
    final features = <String>[];

    if (isFeatureEnabled('ai_chat')) features.add('ai_chat');
    if (isFeatureEnabled('advanced_analytics')) {
      features.add('advanced_analytics');
    }
    if (isFeatureEnabled('enhanced_gamification')) {
      features.add('enhanced_gamification');
    }
    if (isFeatureEnabled('advanced_caching')) features.add('advanced_caching');
    if (isFeatureEnabled('voice_control')) features.add('voice_control');
    if (isFeatureEnabled('predictive_analytics')) {
      features.add('predictive_analytics');
    }
    if (isFeatureEnabled('social_features')) features.add('social_features');
    if (isFeatureEnabled('performance_optimization')) {
      features.add('performance_optimization');
    }

    return features;
  }

  /// Enable/disable features for testing
  static void toggleFeature(String feature, bool enabled) {
    switch (feature) {
      case 'ai_chat':
        aiChatEnabled = enabled;
        break;
      case 'advanced_analytics':
        advancedAnalyticsEnabled = enabled;
        break;
      case 'enhanced_gamification':
        enhancedGamificationEnabled = enabled;
        break;
      case 'advanced_caching':
        advancedCachingEnabled = enabled;
        break;
      case 'voice_control':
        voiceControlEnabled = enabled;
        break;
      case 'predictive_analytics':
        predictiveAnalyticsEnabled = enabled;
        break;
      case 'social_features':
        socialFeaturesEnabled = enabled;
        break;
      case 'performance_optimization':
        performanceOptimizationEnabled = enabled;
        break;
    }
  }
}
