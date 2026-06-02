import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';

/// Gradient header widget used across Home, Doctor Detail, Profile screens
class AppGradientHeader extends StatelessWidget {
  final String? greeting;
  final String? title;
  final String? subtitle;
  final String? avatarUrl;
  final String? avatarInitial;
  final List<Widget>? actions;
  final Widget? trailing;
  final double height;
  final bool showAvatar;
  final LinearGradient? gradient;

  const AppGradientHeader({
    super.key,
    this.greeting,
    this.title,
    this.subtitle,
    this.avatarUrl,
    this.avatarInitial,
    this.actions,
    this.trailing,
    this.height = 180,
    this.showAvatar = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.lg,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.heroGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSpacing.radiusXxl),
          bottomRight: Radius.circular(AppSpacing.radiusXxl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with avatar and actions
          Row(
            children: [
              if (showAvatar) ...[
                Container(
                  width: AppSpacing.avatarMd,
                  height: AppSpacing.avatarMd,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                    image: avatarUrl != null
                        ? DecorationImage(image: NetworkImage(avatarUrl!), fit: BoxFit.cover)
                        : null,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: avatarUrl == null
                      ? Center(
                          child: Text(
                            avatarInitial ?? '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                ),
                AppSpacing.gapHMd,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (greeting != null)
                      Text(
                        greeting!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                    if (title != null)
                      Text(
                        title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  ],
                ),
              ),
              if (actions != null) ...actions!,
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            AppSpacing.gapMd,
            Text(
              subtitle!,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ],
      ),
    );
  }
}

/// Doctor card widget used in Home, Search, Favorites
class AppDoctorCard extends StatelessWidget {
  final String? name;
  final String? speciality;
  final String? hospital;
  final String? avatarUrl;
  final String? rating;
  final int? ratingCount;
  final int? experience;
  final String? fee;
  final bool isVerified;
  final VoidCallback? onTap;

  const AppDoctorCard({
    super.key,
    this.name,
    this.speciality,
    this.hospital,
    this.avatarUrl,
    this.rating,
    this.ratingCount,
    this.experience,
    this.fee,
    this.isVerified = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: AppSpacing.borderRadiusMd,
                    color: AppColors.primarySurface,
                    image: avatarUrl != null
                        ? DecorationImage(image: NetworkImage(avatarUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: avatarUrl == null
                      ? Center(
                          child: Text(
                            (name ?? 'D')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                AppSpacing.gapHLg,
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name ?? 'Bác sĩ',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (isVerified)
                            const Icon(Icons.verified, size: 18, color: AppColors.primary),
                        ],
                      ),
                      AppSpacing.gapXs,
                      Text(
                        speciality ?? '',
                        style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
                      ),
                      if (hospital != null) ...[
                        AppSpacing.gapXs,
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
                            AppSpacing.gapHXs,
                            Expanded(
                              child: Text(
                                hospital!,
                                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      AppSpacing.gapSm,
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade700),
                          AppSpacing.gapHXs,
                          Text(
                            '${rating ?? '0.0'} (${ratingCount ?? 0})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          if (experience != null) ...[
                            AppSpacing.gapHLg,
                            const Icon(Icons.work_outline, size: 14, color: AppColors.textTertiary),
                            AppSpacing.gapHXs,
                            Text(
                              '$experience năm',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                          const Spacer(),
                          if (fee != null)
                            Text(
                              fee!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Stat card used in Doctor Dashboard, Admin Dashboard
class AppStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final LinearGradient? gradient;

  const AppStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? color.withValues(alpha: 0.08) : null,
        borderRadius: AppSpacing.borderRadiusLg,
        border: gradient == null ? Border.all(color: color.withValues(alpha: 0.2)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: gradient != null ? Colors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.15),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(icon, color: gradient != null ? Colors.white : color, size: 22),
          ),
          AppSpacing.gapMd,
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: gradient != null ? Colors.white : AppColors.textPrimary,
            ),
          ),
          AppSpacing.gapXs,
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: gradient != null ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header with title and optional "See all" button
class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Empty state placeholder
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: AppDecorations.iconContainerCircle(AppColors.textTertiary),
              child: Icon(icon, size: 40, color: AppColors.textTertiary),
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
            AppSpacing.gapXxl,
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            if (subtitle != null) ...[
              AppSpacing.gapSm,
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
            ],
            if (actionText != null && onAction != null) ...[
              AppSpacing.gapXxl,
              FilledButton(
                onPressed: onAction,
                child: Text(actionText!),
              ).animate().fadeIn(delay: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}

/// Search bar widget
class AppSearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    this.hint = 'Tìm kiếm...',
    this.onTap,
    this.onChanged,
    this.readOnly = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? onTap : null,
      child: Container(
        height: AppSpacing.searchBarHeight,
        decoration: AppDecorations.searchBar,
        child: readOnly
            ? Row(
                children: [
                  const SizedBox(width: AppSpacing.lg),
                  const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
                  AppSpacing.gapHMd,
                  Text(hint, style: const TextStyle(color: AppColors.textTertiary, fontSize: 14)),
                ],
              )
            : TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  filled: false,
                ),
              ),
      ),
    );
  }
}

/// Appointment card widget
class AppAppointmentCard extends StatelessWidget {
  final String doctorName;
  final String? speciality;
  final String? avatarUrl;
  final String date;
  final String time;
  final String status;
  final String? consultationType;
  final VoidCallback? onTap;

  const AppAppointmentCard({
    super.key,
    required this.doctorName,
    this.speciality,
    this.avatarUrl,
    required this.date,
    required this.time,
    required this.status,
    this.consultationType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.statusColor(status);

    return Container(
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: AppSpacing.borderRadiusMd,
                        color: AppColors.primarySurface,
                        image: avatarUrl != null
                            ? DecorationImage(image: NetworkImage(avatarUrl!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: avatarUrl == null
                          ? Center(
                              child: Text(
                                doctorName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    AppSpacing.gapHMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctorName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (speciality != null)
                            Text(
                              speciality!,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: AppSpacing.chipPadding,
                      decoration: AppDecorations.statusBadge(status),
                      child: Text(
                        _statusLabel(status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapMd,
                // Date & Time row
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                      AppSpacing.gapHSm,
                      Text(date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      AppSpacing.gapHLg,
                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                      AppSpacing.gapHSm,
                      Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      if (consultationType != null) ...[
                        const Spacer(),
                        Icon(
                          consultationType == 'video' ? Icons.videocam_outlined : Icons.person_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        AppSpacing.gapHXs,
                        Text(
                          consultationType == 'video' ? 'Video' : 'Trực tiếp',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
    'pending' => 'Chờ xác nhận',
    'confirmed' => 'Đã xác nhận',
    'cancelled' => 'Đã hủy',
    'completed' => 'Hoàn thành',
    'no_show' => 'Vắng mặt',
    _ => status,
  };
}

/// Shimmer loading placeholder
class AppShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 80,
    this.borderRadius = AppSpacing.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: AppColors.surface.withValues(alpha: 0.6),
        );
  }
}
