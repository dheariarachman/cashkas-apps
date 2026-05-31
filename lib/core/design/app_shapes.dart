import 'package:flutter/material.dart';

/// Shape tokens for KeuanganAgen.
///
/// Follows the "Rounded" philosophy from DESIGN.md:
///   Standard elements  → 8px
///   Container elements → 16px
///   High-impact / FABs → pill-shaped
abstract final class AppShapes {
  // ── Border Radius ───────────────────────────────────────────────────

  /// 4px – subtle rounding (sm).
  static const double radiusSm = 4;

  /// 8px – standard elements: inputs, small buttons, list items.
  static const double radiusDefault = 8;

  /// 12px – medium containers.
  static const double radiusMd = 12;

  /// 16px – container elements: transaction cards, dashboard widgets.
  static const double radiusLg = 16;

  /// 24px – extra-large.
  static const double radiusXl = 24;

  /// 9999px – full pill / circle.
  static const double radiusFull = 9999;

  // ── Convenience BorderRadius constants ──────────────────────────────

  static final BorderRadius borderRadiusSm =
      BorderRadius.circular(radiusSm);

  static final BorderRadius borderRadiusDefault =
      BorderRadius.circular(radiusDefault);

  static final BorderRadius borderRadiusMd =
      BorderRadius.circular(radiusMd);

  static final BorderRadius borderRadiusLg =
      BorderRadius.circular(radiusLg);

  static final BorderRadius borderRadiusXl =
      BorderRadius.circular(radiusXl);

  static final BorderRadius borderRadiusFull =
      BorderRadius.circular(radiusFull);

  // ── Material ShapeBorder helpers ────────────────────────────────────

  /// Standard element shape (inputs, small buttons).
  static final RoundedRectangleBorder standardShape =
      RoundedRectangleBorder(borderRadius: borderRadiusDefault);

  /// Container shape (cards, widgets).
  static final RoundedRectangleBorder containerShape =
      RoundedRectangleBorder(borderRadius: borderRadiusLg);

  /// Pill shape (FABs, status badges).
  static final StadiumBorder pillShape = const StadiumBorder();
}
