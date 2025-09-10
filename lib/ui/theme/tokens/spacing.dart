/// NDIS Connect Design System - Spacing Tokens
/// Based on 4px grid system for consistent spacing
class NDISSpacing {
  // Base spacing unit (4px)
  static const double base = 4;

  // Spacing scale
  static const double xs = base * 1; // 4px
  static const double sm = base * 2; // 8px
  static const double md = base * 3; // 12px
  static const double lg = base * 4; // 16px
  static const double xl = base * 6; // 24px
  static const double xxl = base * 8; // 32px
  static const double xxxl = base * 12; // 48px
  static const double huge = base * 16; // 64px

  // Component-specific spacing
  static const double buttonPadding = lg; // 16px
  static const double cardPadding = xl; // 24px
  static const double screenPadding = xl; // 24px
  static const double sectionSpacing = xxl; // 32px
  static const double listItemSpacing = md; // 12px
  static const double formFieldSpacing = lg; // 16px

  // Touch target minimums (accessibility)
  static const double minTouchTarget = 44; // 44px minimum
  static const double comfortableTouchTarget = 48; // 48px comfortable

  // Border radius
  static const double radiusXs = base * 1; // 4px
  static const double radiusSm = base * 2; // 8px
  static const double radiusMd = base * 3; // 12px
  static const double radiusLg = base * 4; // 16px
  static const double radiusXl = base * 6; // 24px
  static const double radiusPill = 999; // Pill shape

  // Icon sizes
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 40;

  // Elevation (shadow depth)
  static const double elevationNone = 0;
  static const double elevationLow = 1;
  static const double elevationMedium = 3;
  static const double elevationHigh = 6;
  static const double elevationHighest = 12;
}
