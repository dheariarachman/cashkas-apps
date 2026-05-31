import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_typography.dart';
import '../models/transaction_model.dart';
import 'status_badge.dart';

class FinancialCard extends StatelessWidget {
  final String title;
  final String timestamp;
  final String formattedAmount;
  final String? formattedProfit;
  final TransactionType type;
  final BadgeStatus? badgeStatus;
  final String? badgeLabel;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? leftBorderColor;
  final VoidCallback? onTap;

  const FinancialCard({
    super.key,
    required this.title,
    required this.timestamp,
    required this.formattedAmount,
    this.formattedProfit,
    required this.type,
    this.badgeStatus,
    this.badgeLabel,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.leftBorderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (leftBorderColor != null)
                Container(
                  width: 4,
                  color: leftBorderColor,
                ),
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        // Icon Box
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: iconBackgroundColor ?? AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            icon ?? Icons.receipt_long_outlined,
                            color: iconColor ?? AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: AppTypography.bodyMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (badgeStatus != null && badgeLabel != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: StatusBadge(
                                        label: badgeLabel!,
                                        status: badgeStatus!,
                                      ),
                                    ),
                                  Text(
                                    timestamp,
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.outline,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Trailing
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              formattedAmount,
                              style: AppTypography.numericMd.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            if (formattedProfit != null)
                              Text(
                                formattedProfit!,
                                style: AppTypography.numericMd.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
