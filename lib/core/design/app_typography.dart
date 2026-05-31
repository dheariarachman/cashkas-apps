import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography scale for KeuanganAgen.
///
/// All values are taken from the DESIGN.md specification but reduced for compactness.
/// Uses the `Inter` typeface via Google Fonts.
abstract final class AppTypography {
  /// headline-xl: 40px / 48px / 700 / -0.02em
  static TextStyle get headlineXl => GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 48 / 40,
        letterSpacing: -0.8,
        color: AppColors.onSurface,
      );

  /// headline-lg: 28px / 36px / 600 / -0.01em
  static TextStyle get headlineLg => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 36 / 28,
        letterSpacing: -0.28,
        color: AppColors.onSurface,
      );

  /// headline-lg-mobile: 24px / 32px / 600
  static TextStyle get headlineLgMobile => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: AppColors.onSurface,
      );

  /// headline-md: 20px / 28px / 600
  static TextStyle get headlineMd => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: AppColors.onSurface,
      );

  /// body-lg: 16px / 24px / 400
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  /// body-md: 14px / 20px / 400
  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.onSurface,
      );

  /// body-sm: 12px / 18px / 400
  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 18 / 12,
        color: AppColors.onSurface,
      );

  /// label-md: 11px / 14px / 500 / 0.05em
  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 14 / 11,
        letterSpacing: 0.55,
        color: AppColors.onSurfaceVariant,
      );

  // ─── Numeric roles (tabular-nums for aligned columns) ────────────────

  /// numeric-xl: 24px / 32px / 700
  static TextStyle get numericXl => headlineLgMobile.copyWith(
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// numeric-md: 14px / 20px / 600
  static TextStyle get numericMd => bodyMd.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // ─── Material TextTheme builder ─────────────────────────────────────

  static TextTheme get textTheme => TextTheme(
        displayLarge: headlineXl,
        headlineLarge: headlineLg,
        headlineMedium: headlineMd,
        headlineSmall: headlineLgMobile,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        bodySmall: bodySm,
        labelMedium: labelMd,
        titleLarge: numericXl,
        titleMedium: numericMd,
      );

  // Backward compatibility aliases
  static TextStyle get displayLarge => headlineXl;
  static TextStyle get headlineMedium => headlineMd;
  static TextStyle get headlineSmall => headlineLgMobile;
  static TextStyle get bodyLarge => bodyLg;
  static TextStyle get bodyMedium => bodyMd;
  static TextStyle get labelMedium => labelMd;
}
