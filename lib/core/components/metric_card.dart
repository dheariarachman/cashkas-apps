import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_typography.dart';
import '../design/app_elevation.dart';
import '../design/app_shapes.dart';

/// A card displaying a summary total with a primary blue top border.
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.gridMargin,
        vertical: AppSpacing.stackGap / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppShapes.borderRadiusLg,
        boxShadow: AppElevation.level1,
      ),
      child: Stack(
        children: [
          // Subtle Primary Blue top-border
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppShapes.radiusLg),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.containerPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        value,
                        style: AppTypography.numericXl,
                      ),
                    ],
                  ),
                ),
                if (icon != null)
                  Icon(
                    icon,
                    color: AppColors.primary,
                    size: 32,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
