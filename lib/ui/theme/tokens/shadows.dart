import 'package:flutter/material.dart';

/// NDIS Connect Design System - Shadow Tokens
/// Material Design 3 elevation system
class NDSShadows {
  // Shadow colors
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowColorLight = Color(0x0D000000);
  static const Color shadowColorDark = Color(0x33000000);

  // Elevation levels
  static const double elevationNone = 0;
  static const double elevationLow = 1;
  static const double elevationMedium = 3;
  static const double elevationHigh = 6;
  static const double elevationHighest = 12;

  // Standard shadows
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> low = [
    BoxShadow(
      color: shadowColorLight,
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(0, 1),
      blurRadius: 5,
    ),
    BoxShadow(
      color: shadowColorLight,
      offset: Offset(0, 2),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> high = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(0, 1),
      blurRadius: 8,
    ),
    BoxShadow(
      color: shadowColorLight,
      offset: Offset(0, 3),
      blurRadius: 4,
    ),
  ];

  static const List<BoxShadow> highest = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(0, 2),
      blurRadius: 12,
    ),
    BoxShadow(
      color: shadowColorLight,
      offset: Offset(0, 6),
      blurRadius: 6,
    ),
  ];

  // Component-specific shadows
  static const List<BoxShadow> card = medium;
  static const List<BoxShadow> button = low;
  static const List<BoxShadow> fab = high;
  static const List<BoxShadow> dialog = highest;
  static const List<BoxShadow> bottomSheet = high;
  static const List<BoxShadow> appBar = low;
  static const List<BoxShadow> navigationBar = medium;

  // Interactive shadows (for pressed states)
  static const List<BoxShadow> pressed = [
    BoxShadow(
      color: shadowColorLight,
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  // Focus shadows (for accessibility)
  static const List<BoxShadow> focus = [
    BoxShadow(
      color: Color(0x1A1A73E8), // Primary color with opacity
      spreadRadius: 2,
    ),
  ];

  // Helper method to get shadow by elevation
  static List<BoxShadow> getByElevation(final double elevation) {
    if (elevation <= elevationNone) return none;
    if (elevation <= elevationLow) return low;
    if (elevation <= elevationMedium) return medium;
    if (elevation <= elevationHigh) return high;
    return highest;
  }

  // Helper method to create custom shadow
  static List<BoxShadow> custom({
    required final Color color,
    required final Offset offset,
    required final double blurRadius,
    final double spreadRadius = 0,
  }) => [
      BoxShadow(
        color: color,
        offset: offset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
}
