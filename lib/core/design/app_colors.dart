import 'package:flutter/material.dart';

/// Design-system color tokens for KeuanganAgen.
///
/// Every value is taken verbatim from the DESIGN.md palette so that the
/// implementation stays pixel-perfect with the design specification.
abstract final class AppColors {
  // ── Surface ──────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF424753);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);
  static const Color outline = Color(0xFF727784);
  static const Color outlineVariant = Color(0xFFC2C6D5);
  static const Color surfaceTint = Color(0xFF005AC2);
  static const Color surfaceVariant = Color(0xFFD3E4FE);

  // ── Primary (Trust Blue) ─────────────────────────────────────────────
  static const Color primary = Color(0xFF004496);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF005BC4);
  static const Color onPrimaryContainer = Color(0xFFCBDAFF);
  static const Color inversePrimary = Color(0xFFADC6FF);

  // ── Secondary (Growth Green) ─────────────────────────────────────────
  static const Color secondary = Color(0xFF006E20);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF7FF984);
  static const Color onSecondaryContainer = Color(0xFF007322);

  // ── Tertiary (Midnight Slate) ────────────────────────────────────────
  static const Color tertiary = Color(0xFF3D485C);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF556074);
  static const Color onTertiaryContainer = Color(0xFFD0DBF3);

  // ── Error ────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ── Fixed palettes ──────────────────────────────────────────────────
  static const Color primaryFixed = Color(0xFFD8E2FF);
  static const Color primaryFixedDim = Color(0xFFADC6FF);
  static const Color onPrimaryFixed = Color(0xFF001A42);
  static const Color onPrimaryFixedVariant = Color(0xFF004395);

  static const Color secondaryFixed = Color(0xFF82FC87);
  static const Color secondaryFixedDim = Color(0xFF66DF6E);
  static const Color onSecondaryFixed = Color(0xFF002205);
  static const Color onSecondaryFixedVariant = Color(0xFF005316);

  static const Color tertiaryFixed = Color(0xFFD8E3FB);
  static const Color tertiaryFixedDim = Color(0xFFBCC7DE);
  static const Color onTertiaryFixed = Color(0xFF111C2D);
  static const Color onTertiaryFixedVariant = Color(0xFF3C475A);

  // ── Background (aliases for surface) ────────────────────────────────
  static const Color background = Color(0xFFF8F9FF);
  static const Color onBackground = Color(0xFF0B1C30);

  // ── Semantic helpers ────────────────────────────────────────────────
  static const Color success = Color(0xFF006E20); // Mapping secondary to success as per DESIGN.md
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFF7FF984);
  static const Color onSuccessContainer = Color(0xFF007322);
}
