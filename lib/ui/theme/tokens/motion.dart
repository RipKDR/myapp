import 'package:flutter/material.dart';

/// NDIS Connect Design System - Motion Tokens
/// Accessibility-aware animation system
class NDSMotion {
  // Duration tokens (in milliseconds)
  static const int durationFast = 150;
  static const int durationNormal = 250;
  static const int durationSlow = 350;
  static const int durationSlower = 500;

  // Duration objects
  static const Duration fast = Duration(milliseconds: durationFast);
  static const Duration normal = Duration(milliseconds: durationNormal);
  static const Duration slow = Duration(milliseconds: durationSlow);
  static const Duration slower = Duration(milliseconds: durationSlower);

  // Easing curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeInOutCubic = Curves.easeInOutCubic;
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Curve easeInCubic = Curves.easeInCubic;

  // Material Design curves
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.easeOutCubic;
  static const Curve accelerate = Curves.easeInCubic;
  static const Curve sharp = Curves.easeInOut;

  // Component-specific animations
  static const Duration buttonPress = fast;
  static const Duration cardHover = normal;
  static const Duration pageTransition = slow;
  static const Duration modalTransition = slower;
  static const Duration listItemAnimation = normal;
  static const Duration fabAnimation = normal;
  static const Duration snackbarAnimation = slow;

  // Accessibility-aware durations
  static Duration getAccessibleDuration(
    final Duration baseDuration,
    final bool reduceMotion,
  ) {
    if (reduceMotion) {
      return const Duration();
    }
    return baseDuration;
  }

  // Accessibility-aware curves
  static Curve getAccessibleCurve(final Curve baseCurve, final bool reduceMotion) {
    if (reduceMotion) {
      return Curves.linear;
    }
    return baseCurve;
  }

  // Standard animation configurations
  static Duration getStandardDuration({
    required final Duration duration,
    final bool reduceMotion = false,
  }) => getAccessibleDuration(duration, reduceMotion);

  // Page transition configurations
  static const PageTransitionsTheme pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  // Staggered animation delays
  static const Duration staggerDelay = Duration(milliseconds: 50);

  // Helper method to create staggered delays
  static Duration getStaggeredDelay(
    final int index, {
    final Duration baseDelay = staggerDelay,
  }) => Duration(milliseconds: baseDelay.inMilliseconds * index);
}
