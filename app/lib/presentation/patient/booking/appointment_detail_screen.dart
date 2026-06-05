import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/appointment_model.dart';
import 'package:doctor_booking_app/data/repositories/appointment_repository.dart';

/// Provider to load single appointment from DB
final appointmentDetailProvider = FutureProvider.family<AppointmentModel?, String>((ref, id) async {
  final client = Supabase.instance.client;
  try {
    final data = await client
        .from('appointments')
        .select('*, doctors(*, users(full_name, avatar_url), specialities(name, name_vi))')
        .eq('id', id)
        .single();
    return AppointmentModel.fromJson(data);
  } catch (_) {
    return null;
  }
});

class AppointmentDetailScreen extends ConsumerWidget {
  final String appointmentId;
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aptAsync = ref.watch(appointmentDetailProvider(appointmentId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết lịch hẹn')),
      body: aptAsync.when(
        data: (apt) {
          if (apt == null) {
            return const Center(child: Text('Không tìm thấy lịch hẹn'));
          }
          return _AppointmentDetailBody(appointment: apt, ref: ref);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}

class _AppointmentDetailBody extends StatelessWidget {
  final AppointmentModel appointment;
  final WidgetRef ref;
  const _AppointmentDetailBody({required this.appointment, required this.ref});

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (appointment.status) {
      AppointmentStatus.pending => 'Chờ xác nhận',
      AppointmentStatus.confirmed => 'Đã xác nhận',
      AppointmentStatus.completed => 'Hoàn thành',
      AppointmentStatus.cancelled => 'Đã hủy',
      AppointmentStatus.noShow => 'Vắng mặt',
    };

    final statusColor = switch (appointment.status) {
      AppointmentStatus.confirmed => AppColors.statusConfirmed,
      AppointmentStatus.pending => AppColors.statusPending,
      AppointmentStatus.completed => AppColors.primary,
      AppointmentStatus.cancelled => AppColors.statusCancelled,
      AppointmentStatus.noShow => AppColors.textTertiary,
    };

    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusLg,
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: AppSpacing.borderRadiusSm),
                  child: Icon(
                    appointment.isConfirmed ? Icons.check_circle : Icons.schedule,
                    color: statusColor, size: 22,
                  ),
                ),
                AppSpacing.gapHMd,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(
                      appointment.isVideo ? 'Khám qua Video Call' : 'Khám trực tiếp',
                      style: TextStyle(color: statusColor.withValues(alpha: 0.7), fontSize: 12),
                    ),
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
                  child: Center(child: Text(
                    (appointment.doctorName ?? 'B')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primary),
                  )),
                ),
                AppSpacing.gapHMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BS. ${appointment.doctorName ?? 'Chưa rõ'}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      if (appointment.specialityName != null)
                        Text(appointment.specialityName!, style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
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
                _row(Icons.calendar_today_outlined, 'Ngày', '${appointment.bookingDate.day}/${appointment.bookingDate.month}/${appointment.bookingDate.year}'),
                AppSpacing.gapMd,
                _row(Icons.access_time_rounded, 'Giờ',
                    '${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')} - '
                    '${appointment.endTime.hour.toString().padLeft(2, '0')}:${appointment.endTime.minute.toString().padLeft(2, '0')}'),
                AppSpacing.gapMd,
                _row(Icons.medical_services_outlined, 'Hình thức', appointment.isVideo ? 'Video Call' : 'Trực tiếp'),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
          AppSpacing.gapXxl,

          // Note
          if (appointment.reason != null && appointment.reason!.isNotEmpty) ...[
            const Text('Ghi chú', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            AppSpacing.gapMd,
            Container(
              width: double.infinity,
              decoration: AppDecorations.cardFlat,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(appointment.reason!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
            ).animate().fadeIn(delay: 300.ms),
            AppSpacing.gapXxl,
          ],

          // Actions
          if (appointment.isConfirmed || appointment.isPending) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hủy lịch hẹn?'),
                      content: const Text('Bạn có chắc chắn muốn hủy lịch hẹn này?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                          child: const Text('Hủy lịch'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(appointmentRepositoryProvider).cancelAppointment(appointment.id, 'Bệnh nhân hủy');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã hủy lịch hẹn'), backgroundColor: AppColors.success),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Hủy lịch hẹn'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.error, padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
          AppSpacing.gapXxxl,
        ],
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
