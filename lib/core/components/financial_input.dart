import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_shapes.dart';
import '../design/app_spacing.dart';
import '../design/app_typography.dart';

/// A specialized input field for financial amounts.
/// Features a fixed 'Rp' prefix and large typography.
class FinancialInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const FinancialInput({
    super.key,
    this.controller,
    required this.hintText,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTypography.numericXl,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.sm,
            top: AppSpacing.sm, // Align with text baseline
            bottom: AppSpacing.sm,
          ),
          child: Text(
            'Rp',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        // Use a light-gray fill with a high-contrast bottom border
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppShapes.radiusDefault),
          ),
          borderSide: const BorderSide(
            color: AppColors.outline,
            width: 1,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppShapes.radiusDefault),
          ),
          borderSide: const BorderSide(
            color: AppColors.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppShapes.radiusDefault),
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppShapes.radiusDefault),
          ),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}
