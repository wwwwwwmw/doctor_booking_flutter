import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/presentation/common/auth/login_screen.dart';

/// Screen shown to doctors whose account is pending admin approval
class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.statusPending.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 48,
                  color: AppColors.statusPending,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 800.ms),
              AppSpacing.gapXxl,
              Text(
                'Tài khoản đang chờ duyệt',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              AppSpacing.gapMd,
              Text(
                'Tài khoản bác sĩ của bạn đã được tạo thành công.\n'
                'Vui lòng chờ quản trị viên xét duyệt trước khi đăng nhập.\n\n'
                'Bạn sẽ nhận thông báo khi tài khoản được kích hoạt.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              AppSpacing.gapXxxl,
              // Info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.statusPending.withValues(alpha: 0.08),
                  borderRadius: AppSpacing.borderRadiusLg,
                  border: Border.all(color: AppColors.statusPending.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.statusPending.withValues(alpha: 0.15),
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: AppColors.statusPending, size: 18),
                    ),
                    AppSpacing.gapHMd,
                    const Expanded(
                      child: Text(
                        'Quá trình duyệt thường mất 1-2 ngày làm việc',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms),
              const Spacer(),
              // Back to login button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (r) => false,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Quay lại đăng nhập'),
                ),
              ).animate().fadeIn(delay: 600.ms),
              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }
}
