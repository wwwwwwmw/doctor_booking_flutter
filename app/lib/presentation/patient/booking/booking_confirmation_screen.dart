import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String doctorName;
  final String date;
  final String time;

  const BookingConfirmationScreen({
    super.key,
    required this.doctorName,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPaddingAll,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success icon
              Container(
                width: 100, height: 100,
                decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 56, color: AppColors.success),
              )
                  .animate().fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 800.ms),
              AppSpacing.gapXxl,
              Text(
                'Đặt lịch thành công!',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              AppSpacing.gapMd,
              Text(
                'Lịch hẹn của bạn đã được gửi đến bác sĩ.\nBạn sẽ nhận thông báo khi được xác nhận.',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              AppSpacing.gapXxxl,
              // Booking summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppSpacing.borderRadiusLg,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.person_outlined, 'Bác sĩ', doctorName),
                    AppSpacing.gapMd,
                    _infoRow(Icons.calendar_today_outlined, 'Ngày', date),
                    AppSpacing.gapMd,
                    _infoRow(Icons.access_time_rounded, 'Giờ', time),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
              const Spacer(),
              // Buttons
              FilledButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Về trang chủ'),
              ).animate().fadeIn(delay: 600.ms),
              AppSpacing.gapMd,
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Xem lịch hẹn'),
              ).animate().fadeIn(delay: 700.ms),
              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        AppSpacing.gapHSm,
        Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
