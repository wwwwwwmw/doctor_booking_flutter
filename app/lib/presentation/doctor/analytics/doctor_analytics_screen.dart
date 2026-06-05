import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/appointment_model.dart';
import 'package:doctor_booking_app/data/repositories/appointment_repository.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

/// Provider for doctor's analytics data
final doctorAnalyticsProvider = FutureProvider<List<AppointmentModel>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  return ref.watch(appointmentRepositoryProvider).getDoctorAppointments(userId);
});

class DoctorAnalyticsScreen extends ConsumerWidget {
  const DoctorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(doctorAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: analyticsAsync.when(
        data: (appointments) {
          final totalAppointments = appointments.length;
          final completedCount = appointments.where((a) => a.isCompleted).length;
          final pendingCount = appointments.where((a) => a.isPending).length;
          final cancelledCount = appointments.where((a) => a.isCancelled).length;
          final videoCount = appointments.where((a) => a.isVideo).length;
          final inPersonCount = totalAppointments - videoCount;

          // Unique patients
          final uniquePatients = appointments.map((a) => a.patientId).toSet().length;

          // This month
          final now = DateTime.now();
          final thisMonthCount = appointments.where((a) =>
              a.startTime.year == now.year && a.startTime.month == now.month).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary card
                Container(
                  width: double.infinity,
                  decoration: AppDecorations.cardElevated,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tổng quan', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      AppSpacing.gapXs,
                      Text('$thisMonthCount lịch hẹn tháng này', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      AppSpacing.gapXs,
                      Text('Tổng cộng $totalAppointments lịch hẹn', style: const TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                AppSpacing.gapXxl,

                // Stats grid
                Row(
                  children: [
                    Expanded(child: AppStatCard(icon: Icons.people_rounded, value: '$uniquePatients', label: 'Bệnh nhân', color: AppColors.primary)),
                    AppSpacing.gapHMd,
                    Expanded(child: AppStatCard(icon: Icons.check_circle_outline, value: '$completedCount', label: 'Hoàn thành', color: AppColors.success)),
                  ],
                ),
                AppSpacing.gapMd,
                Row(
                  children: [
                    Expanded(child: AppStatCard(icon: Icons.pending_actions, value: '$pendingCount', label: 'Chờ duyệt', color: AppColors.accent)),
                    AppSpacing.gapHMd,
                    Expanded(child: AppStatCard(icon: Icons.cancel_outlined, value: '$cancelledCount', label: 'Đã hủy', color: AppColors.error)),
                  ],
                ),
                AppSpacing.gapXxl,

                // Appointment type breakdown
                Container(
                  width: double.infinity,
                  decoration: AppDecorations.cardElevated,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Loại khám', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      AppSpacing.gapLg,
                      _StatBar(
                        label: 'Trực tiếp',
                        count: inPersonCount,
                        total: totalAppointments,
                        color: AppColors.primary,
                        icon: Icons.person_rounded,
                      ),
                      AppSpacing.gapMd,
                      _StatBar(
                        label: 'Video Call',
                        count: videoCount,
                        total: totalAppointments,
                        color: AppColors.success,
                        icon: Icons.videocam_rounded,
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapXxl,

                // Status breakdown
                Container(
                  width: double.infinity,
                  decoration: AppDecorations.cardElevated,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Trạng thái lịch hẹn', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      AppSpacing.gapLg,
                      _StatBar(label: 'Hoàn thành', count: completedCount, total: totalAppointments, color: AppColors.success, icon: Icons.check_circle_outline),
                      AppSpacing.gapMd,
                      _StatBar(label: 'Đã xác nhận', count: appointments.where((a) => a.isConfirmed).length, total: totalAppointments, color: AppColors.primary, icon: Icons.verified_outlined),
                      AppSpacing.gapMd,
                      _StatBar(label: 'Chờ duyệt', count: pendingCount, total: totalAppointments, color: AppColors.accent, icon: Icons.pending_actions),
                      AppSpacing.gapMd,
                      _StatBar(label: 'Đã hủy', count: cancelledCount, total: totalAppointments, color: AppColors.error, icon: Icons.cancel_outlined),
                    ],
                  ),
                ),

                if (appointments.isEmpty) ...[
                  AppSpacing.gapXxl,
                  const AppEmptyState(
                    icon: Icons.analytics_outlined,
                    title: 'Chưa có dữ liệu',
                    subtitle: 'Thống kê sẽ hiển thị khi có lịch hẹn',
                  ),
                ],
                AppSpacing.gapXxxl,
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  const _StatBar({required this.label, required this.count, required this.total, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: AppDecorations.iconContainer(color),
          child: Icon(icon, size: 16, color: color),
        ),
        AppSpacing.gapHMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Text('$count', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                ],
              ),
              AppSpacing.gapXs,
              ClipRRect(
                borderRadius: AppSpacing.borderRadiusRound,
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceVariant,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
