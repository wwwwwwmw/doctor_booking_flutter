import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/presentation/common/auth/login_screen.dart';
import 'package:doctor_booking_app/presentation/common/settings/settings_screen.dart';
import 'package:doctor_booking_app/presentation/common/notifications/notifications_screen.dart';
import 'package:doctor_booking_app/presentation/doctor/analytics/doctor_analytics_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
                  Container(
                    width: AppSpacing.avatarXl,
                    height: AppSpacing.avatarXl,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                    ),
                    child: const Icon(Icons.medical_services_rounded, size: 40, color: Colors.white),
                  ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                  AppSpacing.gapMd,
                  const Text('BS. Nguyễn Văn X', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)).animate().fadeIn(delay: 100.ms),
                  AppSpacing.gapXs,
                  const Text('Tim mạch', style: TextStyle(fontSize: 14, color: Colors.white70)),
                  AppSpacing.gapSm,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_rounded, size: 16, color: Colors.white),
                      AppSpacing.gapHXs,
                      Text('Đã xác minh', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                    ],
                  ),
                  AppSpacing.gapXxl,
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatPill(value: '4.8', label: 'Đánh giá'),
                      _StatPill(value: '128', label: 'Bệnh nhân'),
                      _StatPill(value: '10', label: 'Năm KN'),
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
                  const Text('Quản lý', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
                  AppSpacing.gapMd,
                  Container(
                    decoration: AppDecorations.cardFlat,
                    child: Column(
                      children: [
                        _MenuItem(icon: Icons.edit_outlined, color: AppColors.primary, title: 'Chỉnh sửa hồ sơ', onTap: () {}),
                        AppDecorations.thinDivider,
                        _MenuItem(icon: Icons.schedule_rounded, color: AppColors.accent, title: 'Giờ làm việc', onTap: () {}),
                        AppDecorations.thinDivider,
                        _MenuItem(icon: Icons.monetization_on_outlined, color: AppColors.success, title: 'Phí khám: 300.000đ', onTap: () {}),
                        AppDecorations.thinDivider,
                        _MenuItem(icon: Icons.star_outline_rounded, color: Colors.amber.shade700, title: 'Đánh giá (56)', onTap: () {}),
                        AppDecorations.thinDivider,
                        _MenuItem(icon: Icons.analytics_outlined, color: AppColors.secondary, title: 'Thống kê', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorAnalyticsScreen()))),
                        AppDecorations.thinDivider,
                        _MenuItem(icon: Icons.description_outlined, color: AppColors.primary, title: 'Chứng chỉ & Bằng cấp', onTap: () {}),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  AppSpacing.gapXxl,
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
                  ).animate().fadeIn(delay: 400.ms),
                  AppSpacing.gapXxl,
                  Container(
                    decoration: AppDecorations.cardFlat,
                    child: _MenuItem(icon: Icons.logout_rounded, color: AppColors.error, title: 'Đăng xuất', onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                    }),
                  ).animate().fadeIn(delay: 500.ms),
                  AppSpacing.gapXxxl,
                ],
              ),
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
