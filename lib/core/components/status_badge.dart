import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_shapes.dart';
import '../design/app_spacing.dart';
import '../design/app_typography.dart';

/// Predefined statuses for KeuanganAgen based on DESIGN.md
enum BadgeStatus {
  /// Primary Blue for income / Paid (Lunas)
  lunas,
  /// Tertiary Slate/Grey for debt / Piutang
  piutang,
  /// Neutral for other information
  neutral,
}

/// A pill-shaped status badge using low-opacity semantic colors
/// as background fills with high-opacity text.
class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeStatus status;

  const StatusBadge({
    super.key,
    required this.label,
    this.status = BadgeStatus.neutral,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case BadgeStatus.lunas:
        // Use Primary Blue theme for Lunas to avoid Green
        backgroundColor = AppColors.primaryContainer.withOpacity(0.12);
        textColor = AppColors.primary;
        break;
      case BadgeStatus.piutang:
        // Use Tertiary Slate for Piutang
        backgroundColor = AppColors.tertiaryContainer.withOpacity(0.12);
        textColor = AppColors.tertiary;
        break;
      case BadgeStatus.neutral:
        backgroundColor = AppColors.surfaceContainerHigh;
        textColor = AppColors.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppShapes.borderRadiusFull,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelMd.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
