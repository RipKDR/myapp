/// NDIS Connect Design System - Border Radius Tokens
/// Consistent corner radius values for components
class NDSRadius {
  // Base radius unit (4px)
  static const double base = 4;

  // Standard radius values
  static const double none = 0;
  static const double xs = base * 1; // 4px
  static const double sm = base * 2; // 8px
  static const double md = base * 3; // 12px
  static const double lg = base * 4; // 16px
  static const double xl = base * 6; // 24px
  static const double xxl = base * 8; // 32px
  static const double pill = 999; // Fully rounded

  // Component-specific radius
  static const double button = xl; // 24px - pill buttons
  static const double card = md; // 12px - cards
  static const double input = md; // 12px - form inputs
  static const double chip = lg; // 16px - chips
  static const double fab = lg; // 16px - floating action button
  static const double dialog = lg; // 16px - dialogs
  static const double bottomSheet = lg; // 16px - bottom sheets
  static const double snackbar = sm; // 8px - snackbars
  static const double avatar = pill; // Fully rounded avatars
  static const double badge = pill; // Fully rounded badges

  // Special cases
  static const double image = sm; // 8px - images
  static const double icon = xs; // 4px - icon containers
  static const double progress = pill; // Fully rounded progress bars
}
