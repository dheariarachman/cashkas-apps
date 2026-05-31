/// Spacing tokens for KeuanganAgen.
///
/// Built on a 4px / 8px incremental grid as defined in DESIGN.md.
abstract final class AppSpacing {
  /// The base unit (8 px). Multiply to derive larger values.
  static const double base = 8;

  // ── Named tokens from DESIGN.md ──────────────────────────────────────

  /// Gutter between grid columns (24 px).
  static const double gutter = 24;

  /// side margin for mobile (12 px).
  static const double marginMobile = 12;

  /// side margin for desktop (32 px).
  static const double marginDesktop = 32;

  /// Maximum container width (1280 px).
  static const double containerMax = 1280;

  // ── Functional legacy aliases ───────────────────────────────────────
  // Kept for UI stability where gridMargin was used.

  /// Padding inside container edges (12 px).
  static const double containerPadding = 12;

  /// Vertical gap between stacked elements such as cards (8 px).
  static const double stackGap = 8;

  /// Horizontal margins for the full-width mobile grid (12 px).
  static const double gridMargin = 12;

  // ── Derived convenience values ──────────────────────────────────────

  /// 4 px
  static const double xs = 4;

  /// 8 px
  static const double sm = 6;

  /// 12 px
  static const double md = 8;

  /// 16 px
  static const double lg = 12;

  /// 24 px
  static const double xl = 16;

  /// 32 px
  static const double xxl = 24;

  /// 48 px
  static const double xxxl = 32;

  /// 64 px
  static const double xxxxl = 48;

  // ── Touch target ────────────────────────────────────────────────────

  /// Minimum interactive element height (48 px).
  static const double minTouchTarget = 48;

  /// Recommended primary button height (48–56 px).
  static const double buttonHeight = 52;
}
