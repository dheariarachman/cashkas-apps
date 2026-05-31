import 'package:flutter/material.dart';

/// Elevation & shadow tokens for KeuanganAgen.
///
/// Based on the tonal layers and ambient shadows defined in DESIGN.md.
abstract final class AppElevation {
  // ── Box Shadows ─────────────────────────────────────────────────────

  /// Surface-Low: Used for cards and containers.
  /// DESIGN.md: no shadow (flat), feature a subtle 1px border.
  static const List<BoxShadow> low = [];

  /// Surface-High: Used for modals, dropdowns, and elevated action panels.
  /// DESIGN.md: 0px 4px 20px rgba(0, 0, 0, 0.05)
  static const List<BoxShadow> high = [
    BoxShadow(
      color: Color(0x0D000000), // 5 % opacity (rgba(0, 0, 0, 0.05))
      offset: Offset(0, 4),
      blurRadius: 20,
    ),
  ];

  // ── Material elevation values (for widgets that use `elevation`) ────

  /// Material elevation for low surfaces.
  static const double elevationLow = 0;

  /// Material elevation for high surfaces.
  static const double elevationHigh = 4;

  // ── Interactive Depth ───────────────────────────────────────────────

  /// On hover/active, buttons and cards transition with a slight scale increase.
  static const double activeScale = 1.02;

  // ── Legacy Compatibility ────────────────────────────────────────────
  static const List<BoxShadow> level1 = low;
  static const List<BoxShadow> level2 = high;
}
