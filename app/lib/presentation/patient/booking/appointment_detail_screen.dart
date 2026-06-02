import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String appointmentId;
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    // Mock data — will connect to repository
    const status = 'confirmed';

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết lịch hẹn')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppSpacing.borderRadiusLg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: AppSpacing.borderRadiusSm),
                    child: const Icon(Icons.check_circle, color: Colors.white, size: 22),
                  ),
                  AppSpacing.gapHMd,
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Đã xác nhận', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('Lịch hẹn của bạn đã được xác nhận', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            AppSpacing.gapXxl,

            // Doctor card
            Container(
              decoration: AppDecorations.cardElevated,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(borderRadius: AppSpacing.borderRadiusMd, color: AppColors.primarySurface),
                    child: const Center(child: Text('N', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primary))),
                  ),
                  AppSpacing.gapHMd,
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BS. Nguyễn Văn X', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        SizedBox(height: 2),
                        Text('Tim mạch', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                        SizedBox(height: 2),
                        Text('BV Đại học Y Dược', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified, size: 18, color: AppColors.primary),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),
            AppSpacing.gapXxl,

            // Details
            const Text('Thông tin lịch hẹn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            AppSpacing.gapMd,
            Container(
              decoration: AppDecorations.cardFlat,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _row(Icons.calendar_today_outlined, 'Ngày', 'Thứ 3, 20/05/2026'),
                  AppSpacing.gapMd,
                  _row(Icons.access_time_rounded, 'Giờ', '09:00 - 09:30'),
                  AppSpacing.gapMd,
                  _row(Icons.medical_services_outlined, 'Hình thức', 'Trực tiếp'),
                  AppSpacing.gapMd,
                  _row(Icons.payments_outlined, 'Phí khám', '300.000đ'),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            AppSpacing.gapXxl,

            // Note
            const Text('Ghi chú', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            AppSpacing.gapMd,
            Container(
              width: double.infinity,
              decoration: AppDecorations.cardFlat,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: const Text('Tôi bị đau ngực thỉnh thoảng khi tập thể dục.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
            ).animate().fadeIn(delay: 300.ms),
            AppSpacing.gapXxl,

            // Actions
            if (status == 'confirmed') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_calendar, size: 18),
                      label: const Text('Đổi lịch'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  AppSpacing.gapHMd,
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Hủy lịch'),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.error, padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
              AppSpacing.gapMd,
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Nhắn tin với bác sĩ'),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
            AppSpacing.gapXxxl,
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
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
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
