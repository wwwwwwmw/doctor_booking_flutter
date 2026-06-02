import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Reusable decorations — shadows, gradients, glass effects, borders
class AppDecorations {
  AppDecorations._();

  // ──────────── Card Shadows ────────────
  static List<BoxShadow> get shadowXs => [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.10),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> get shadowPrimary => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // ──────────── Card Decorations ────────────
  static BoxDecoration get card => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppSpacing.borderRadiusLg,
    boxShadow: shadowSm,
  );

  static BoxDecoration get cardElevated => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppSpacing.borderRadiusLg,
    boxShadow: shadowMd,
  );

  static BoxDecoration get cardFlat => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppSpacing.borderRadiusMd,
    border: Border.all(color: AppColors.border, width: 1),
  );

  static BoxDecoration get cardSelected => BoxDecoration(
    color: AppColors.primarySurface,
    borderRadius: AppSpacing.borderRadiusMd,
    border: Border.all(color: AppColors.primary, width: 1.5),
  );

  // ──────────── Gradient Decorations ────────────
  static BoxDecoration get gradientPrimary => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: AppSpacing.borderRadiusXl,
  );

  static BoxDecoration get gradientHero => const BoxDecoration(
    gradient: AppColors.heroGradient,
  );

  static BoxDecoration get gradientHeroRounded => BoxDecoration(
    gradient: AppColors.heroGradient,
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(AppSpacing.radiusXxl),
      bottomRight: Radius.circular(AppSpacing.radiusXxl),
    ),
  );

  // ──────────── Chip / Badge Decorations ────────────
  static BoxDecoration chipDecoration(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: AppSpacing.borderRadiusRound,
  );

  static BoxDecoration statusBadge(String status) => BoxDecoration(
    color: AppColors.statusBgColor(status),
    borderRadius: AppSpacing.borderRadiusSm,
  );

  // ──────────── Icon Container ────────────
  static BoxDecoration iconContainer(Color color, {double radius = 12}) => BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(radius),
  );

  static BoxDecoration iconContainerCircle(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.12),
    shape: BoxShape.circle,
  );

  // ──────────── Input Decorations ────────────
  static BoxDecoration get searchBar => BoxDecoration(
    color: AppColors.surfaceVariant,
    borderRadius: AppSpacing.borderRadiusMd,
    border: Border.all(color: AppColors.border, width: 1),
  );

  static BoxDecoration get searchBarFocused => BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppSpacing.borderRadiusMd,
    border: Border.all(color: AppColors.primary, width: 1.5),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.12),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // ──────────── Glass Effect ────────────
  static BoxDecoration get glass => BoxDecoration(
    color: AppColors.surface.withValues(alpha: 0.85),
    borderRadius: AppSpacing.borderRadiusLg,
    border: Border.all(
      color: AppColors.surface.withValues(alpha: 0.5),
      width: 1,
    ),
    boxShadow: shadowSm,
  );

  // ──────────── Bottom Sheet ────────────
  static BoxDecoration get bottomSheet => const BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(AppSpacing.radiusXxl),
      topRight: Radius.circular(AppSpacing.radiusXxl),
    ),
  );

  // ──────────── Divider ────────────
  static Widget get thinDivider => const Divider(
    height: 1,
    thickness: 1,
    color: AppColors.borderLight,
  );
}
