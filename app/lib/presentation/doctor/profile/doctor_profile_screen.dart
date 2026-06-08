import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/user_model.dart';
import 'package:doctor_booking_app/data/models/doctor_model.dart';
import 'package:doctor_booking_app/data/repositories/auth_repository.dart';
import 'package:doctor_booking_app/data/repositories/doctor_repository.dart';
import 'package:doctor_booking_app/presentation/common/auth/login_screen.dart';
import 'package:doctor_booking_app/presentation/common/profile/profile_edit_screen.dart';
import 'package:doctor_booking_app/presentation/common/settings/settings_screen.dart';
import 'package:doctor_booking_app/presentation/common/notifications/notifications_screen.dart';
import 'package:doctor_booking_app/presentation/doctor/analytics/doctor_analytics_screen.dart';

/// Doctor profile provider — load from DB
final doctorProfileProvider = FutureProvider<UserModel>((ref) {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  return ref.watch(authRepositoryProvider).getUserProfile(userId);
});

/// Doctor detail for profile stats
final doctorProfileStatsProvider = FutureProvider<DoctorModel?>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  try {
    return await ref.watch(doctorRepositoryProvider).getDoctorById(userId);
  } catch (_) {
    return null;
  }
});

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(doctorProfileProvider);

    return Scaffold(
      body: profileAsync.when(
        data: (user) => _DoctorProfileContent(user: user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              AppSpacing.gapMd,
              Text('Lỗi: $e', textAlign: TextAlign.center),
              AppSpacing.gapMd,
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: () => ref.invalidate(doctorProfileProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorProfileContent extends ConsumerWidget {
  final UserModel user;
  const _DoctorProfileContent({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorStats = ref.watch(doctorProfileStatsProvider);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppSpacing.xxl,
              bottom: AppSpacing.xxxl,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppSpacing.radiusXxl),
                bottomRight: Radius.circular(AppSpacing.radiusXxl),
              ),
            ),
            child: Column(
              children: [
                // Avatar — load from user data
                Container(
                  width: AppSpacing.avatarXl,
                  height: AppSpacing.avatarXl,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                    image: user.avatarUrl != null
                        ? DecorationImage(image: NetworkImage(user.avatarUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: user.avatarUrl == null
                      ? Center(
                          child: Text(
                            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'D',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        )
                      : null,
                ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                AppSpacing.gapMd,
                // Name from DB
                Text(
                  'BS. ${user.fullName}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                ).animate().fadeIn(delay: 100.ms),
                AppSpacing.gapXs,
                // Email
                Text(user.email, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                AppSpacing.gapSm,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_rounded, size: 16, color: Colors.white),
                    AppSpacing.gapHXs,
                    Text('Bác sĩ', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                  ],
                ),
                AppSpacing.gapXxl,
                // Stats from DB
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatPill(
                      value: doctorStats.when(
                        data: (d) => d != null ? d.displayRating : '--',
                        loading: () => '...',
                        error: (_, __) => '--',
                      ),
                      label: 'Đánh giá',
                    ),
                    _StatPill(
                      value: doctorStats.when(
                        data: (d) => d != null ? '${d.ratingCount}' : '0',
                        loading: () => '...',
                        error: (_, __) => '0',
                      ),
                      label: 'Đánh giá',
                    ),
                    _StatPill(
                      value: doctorStats.when(
                        data: (d) => d != null ? '${d.experienceYears}' : '0',
                        loading: () => '...',
                        error: (_, __) => '0',
                      ),
                      label: 'Năm KN',
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: AppSpacing.screenPaddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal info section
                const Text('Thông tin cá nhân', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
                AppSpacing.gapMd,
                Container(
                  decoration: AppDecorations.cardFlat,
                  child: Column(
                    children: [
                      _InfoRow(icon: Icons.email_outlined, label: 'Email', value: user.email),
                      AppDecorations.thinDivider,
                      _InfoRow(icon: Icons.phone_outlined, label: 'Điện thoại', value: user.phone ?? 'Chưa cập nhật'),
                      AppDecorations.thinDivider,
                      _InfoRow(
                        icon: Icons.cake_outlined,
                        label: 'Ngày sinh',
                        value: user.dateOfBirth != null
                            ? '${user.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}'
                            : 'Chưa cập nhật',
                      ),
                      AppDecorations.thinDivider,
                      _InfoRow(
                        icon: Icons.wc_outlined,
                        label: 'Giới tính',
                        value: user.gender == 'male' ? 'Nam' : user.gender == 'female' ? 'Nữ' : 'Chưa cập nhật',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
                AppSpacing.gapXxl,

                // Management section
                const Text('Quản lý', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
                AppSpacing.gapMd,
                Container(
                  decoration: AppDecorations.cardFlat,
                  child: Column(
                    children: [
                      _MenuItem(icon: Icons.edit_outlined, color: AppColors.primary, title: 'Chỉnh sửa hồ sơ', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen()))),
                      AppDecorations.thinDivider,
                      _MenuItem(icon: Icons.schedule_rounded, color: AppColors.accent, title: 'Giờ làm việc', onTap: () {}),
                      AppDecorations.thinDivider,
                      _MenuItem(icon: Icons.monetization_on_outlined, color: AppColors.success, title: 'Phí khám', onTap: () {}),
                      AppDecorations.thinDivider,
                      _MenuItem(icon: Icons.star_outline_rounded, color: Colors.amber.shade700, title: 'Đánh giá', onTap: () {}),
                      AppDecorations.thinDivider,
                      _MenuItem(icon: Icons.analytics_outlined, color: AppColors.secondary, title: 'Thống kê', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorAnalyticsScreen()))),
                      AppDecorations.thinDivider,
                      _MenuItem(icon: Icons.description_outlined, color: AppColors.primary, title: 'Chứng chỉ & Bằng cấp', onTap: () {}),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
                AppSpacing.gapXxl,

                // System section
                const Text('Hệ thống', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
                AppSpacing.gapMd,
                Container(
                  decoration: AppDecorations.cardFlat,
                  child: Column(
                    children: [
                      _MenuItem(icon: Icons.notifications_outlined, color: AppColors.accent, title: 'Thông báo', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                      AppDecorations.thinDivider,
                      _MenuItem(icon: Icons.settings_outlined, color: AppColors.textSecondary, title: 'Cài đặt', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
                      AppDecorations.thinDivider,
                      _MenuItem(icon: Icons.help_outline_rounded, color: AppColors.primary, title: 'Trợ giúp', onTap: () {}),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms),
                AppSpacing.gapXxl,

                // Logout
                Container(
                  decoration: AppDecorations.cardFlat,
                  child: _MenuItem(
                    icon: Icons.logout_rounded,
                    color: AppColors.error,
                    title: 'Đăng xuất',
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (r) => false,
                      );
                    },
                  ),
                ).animate().fadeIn(delay: 600.ms),
                AppSpacing.gapXxxl,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: AppDecorations.iconContainer(AppColors.primary),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          AppSpacing.gapHMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value, label;
  const _StatPill({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: AppSpacing.borderRadiusRound),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.color, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          child: Row(
            children: [
              Container(width: 36, height: 36, decoration: AppDecorations.iconContainer(color), child: Icon(icon, size: 18, color: color)),
              AppSpacing.gapHMd,
              Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
