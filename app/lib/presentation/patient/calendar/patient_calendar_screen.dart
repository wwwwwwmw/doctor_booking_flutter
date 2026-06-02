import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/appointment_model.dart';
import 'package:doctor_booking_app/data/repositories/appointment_repository.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

final patientAppointmentsProvider = FutureProvider<List<AppointmentModel>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  return ref.watch(appointmentRepositoryProvider).getPatientAppointments(userId);
});

class PatientCalendarScreen extends ConsumerStatefulWidget {
  const PatientCalendarScreen({super.key});

  @override
  ConsumerState<PatientCalendarScreen> createState() => _PatientCalendarScreenState();
}

class _PatientCalendarScreenState extends ConsumerState<PatientCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(patientAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch hẹn')),
      body: appointmentsAsync.when(
        data: (appointments) {
          final selectedAppointments = appointments.where((a) =>
              a.bookingDate.year == _selectedDay.year &&
              a.bookingDate.month == _selectedDay.month &&
              a.bookingDate.day == _selectedDay.day).toList();

          return Column(
            children: [
              // Calendar
              Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                decoration: AppDecorations.card,
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                  onDaySelected: (selected, focused) {
                    setState(() { _selectedDay = selected; _focusedDay = focused; });
                  },
                  eventLoader: (day) => appointments.where((a) =>
                      a.bookingDate.year == day.year &&
                      a.bookingDate.month == day.month &&
                      a.bookingDate.day == day.day).toList(),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    todayDecoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                    todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    markerDecoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    markerSize: 6,
                  ),
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                ),
              ),

              // Section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Text(
                      'Ngày ${_selectedDay.day}/${_selectedDay.month}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Container(
                      padding: AppSpacing.chipPadding,
                      decoration: AppDecorations.chipDecoration(AppColors.primary),
                      child: Text(
                        '${selectedAppointments.length} lịch hẹn',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: selectedAppointments.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.event_available_rounded,
                        title: 'Không có lịch hẹn',
                        subtitle: 'Chọn ngày khác hoặc đặt lịch mới',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        itemCount: selectedAppointments.length,
                        itemBuilder: (context, index) {
                          return _AppointmentTile(appointment: selectedAppointments[index]);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppEmptyState(
          icon: Icons.error_outline,
          title: 'Không tải được lịch hẹn',
          subtitle: '$e',
          actionText: 'Thử lại',
          onAction: () => ref.invalidate(patientAppointmentsProvider),
        ),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentTile({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (appointment.status) {
      AppointmentStatus.confirmed => AppColors.statusConfirmed,
      AppointmentStatus.pending => AppColors.statusPending,
      AppointmentStatus.completed => AppColors.primary,
      AppointmentStatus.cancelled => AppColors.statusCancelled,
      AppointmentStatus.noShow => AppColors.textTertiary,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: AppDecorations.card,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 4, height: 48,
              decoration: BoxDecoration(color: statusColor, borderRadius: AppSpacing.borderRadiusRound),
            ),
            AppSpacing.gapHMd,
            Container(
              width: 44, height: 44,
              decoration: AppDecorations.iconContainer(
                appointment.isVideo ? AppColors.success : AppColors.primary,
              ),
              child: Icon(
                appointment.isVideo ? Icons.videocam_rounded : Icons.person_rounded,
                color: appointment.isVideo ? AppColors.success : AppColors.primary, size: 22,
              ),
            ),
            AppSpacing.gapHMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.doctorName ?? 'Bác sĩ',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  AppSpacing.gapXs,
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textTertiary),
                      AppSpacing.gapHXs,
                      Text(
                        '${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')} - '
                        '${appointment.endTime.hour.toString().padLeft(2, '0')}:${appointment.endTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (appointment.specialityName != null) ...[
                    AppSpacing.gapXs,
                    Text(appointment.specialityName!, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ],
                ],
              ),
            ),
            Container(
              padding: AppSpacing.chipPadding,
              decoration: AppDecorations.statusBadge(appointment.status.name),
              child: Text(
                switch (appointment.status) {
                  AppointmentStatus.pending => 'Chờ',
                  AppointmentStatus.confirmed => 'Xác nhận',
                  AppointmentStatus.completed => 'Hoàn thành',
                  AppointmentStatus.cancelled => 'Đã hủy',
                  AppointmentStatus.noShow => 'Vắng',
                },
                style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
