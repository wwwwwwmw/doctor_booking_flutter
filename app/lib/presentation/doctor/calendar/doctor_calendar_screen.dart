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

/// Reuse the provider from doctor_home or define separately
final doctorCalendarAppointmentsProvider = FutureProvider<List<AppointmentModel>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  return ref.watch(appointmentRepositoryProvider).getDoctorAppointments(userId);
});

class DoctorCalendarScreen extends ConsumerStatefulWidget {
  const DoctorCalendarScreen({super.key});

  @override
  ConsumerState<DoctorCalendarScreen> createState() => _DoctorCalendarScreenState();
}

class _DoctorCalendarScreenState extends ConsumerState<DoctorCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(doctorCalendarAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch làm việc'),
        actions: [
          IconButton(icon: const Icon(Icons.today_rounded), onPressed: () => setState(() {
            _focusedDay = DateTime.now();
            _selectedDay = DateTime.now();
          })),
        ],
      ),
      body: appointmentsAsync.when(
        data: (appointments) {
          final dayAppointments = appointments.where((a) =>
              a.startTime.year == _selectedDay.year &&
              a.startTime.month == _selectedDay.month &&
              a.startTime.day == _selectedDay.day).toList();

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                decoration: AppDecorations.card,
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 90)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                  onDaySelected: (selected, focused) => setState(() {
                    _selectedDay = selected; _focusedDay = focused;
                  }),
                  eventLoader: (day) => appointments.where((a) =>
                      a.startTime.year == day.year &&
                      a.startTime.month == day.month &&
                      a.startTime.day == day.day).toList(),
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                    todayTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    markerDecoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    markerSize: 6,
                  ),
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: AppSectionHeader(title: '${dayAppointments.length} lịch hẹn'),
              ),
              Expanded(
                child: dayAppointments.isEmpty
                    ? const AppEmptyState(icon: Icons.event_available_rounded, title: 'Không có lịch hẹn', subtitle: 'Chưa có lịch hẹn nào trong ngày này')
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        itemCount: dayAppointments.length,
                        itemBuilder: (context, index) {
                          final apt = dayAppointments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            decoration: AppDecorations.card,
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4, height: 48,
                                    decoration: BoxDecoration(
                                      color: apt.isPending ? AppColors.statusPending : AppColors.statusConfirmed,
                                      borderRadius: AppSpacing.borderRadiusRound,
                                    ),
                                  ),
                                  AppSpacing.gapHMd,
                                  Container(
                                    width: 40, height: 40,
                                    decoration: AppDecorations.iconContainer(apt.isVideo ? AppColors.success : AppColors.primary),
                                    child: Icon(apt.isVideo ? Icons.videocam_rounded : Icons.person_rounded, color: apt.isVideo ? AppColors.success : AppColors.primary, size: 20),
                                  ),
                                  AppSpacing.gapHMd,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(apt.patientName ?? 'Bệnh nhân', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        AppSpacing.gapXs,
                                        Text(
                                          '${apt.startTime.hour.toString().padLeft(2, '0')}:${apt.startTime.minute.toString().padLeft(2, '0')} - '
                                          '${apt.endTime.hour.toString().padLeft(2, '0')}:${apt.endTime.minute.toString().padLeft(2, '0')} • '
                                          '${apt.isVideo ? 'Video' : 'Trực tiếp'}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (apt.isPending) ...[
                                    _miniBtn(Icons.check_rounded, AppColors.success, () async {
                                      await ref.read(appointmentRepositoryProvider).updateStatus(apt.id, AppointmentStatus.confirmed);
                                      ref.invalidate(doctorCalendarAppointmentsProvider);
                                    }),
                                    AppSpacing.gapHSm,
                                    _miniBtn(Icons.close_rounded, AppColors.error, () async {
                                      await ref.read(appointmentRepositoryProvider).updateStatus(apt.id, AppointmentStatus.cancelled);
                                      ref.invalidate(doctorCalendarAppointmentsProvider);
                                    }),
                                  ] else
                                    Container(
                                      padding: AppSpacing.chipPadding,
                                      decoration: AppDecorations.statusBadge(apt.status.name),
                                      child: Text(
                                        switch (apt.status) {
                                          AppointmentStatus.confirmed => 'Xác nhận',
                                          AppointmentStatus.completed => 'Hoàn thành',
                                          AppointmentStatus.cancelled => 'Đã hủy',
                                          _ => apt.status.name,
                                        },
                                        style: TextStyle(
                                          fontSize: 11, fontWeight: FontWeight.w600,
                                          color: apt.isConfirmed ? AppColors.statusConfirmed : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
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
          onAction: () => ref.invalidate(doctorCalendarAppointmentsProvider),
        ),
      ),
    );
  }

  Widget _miniBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 32, height: 32, decoration: AppDecorations.iconContainer(color), child: Icon(icon, size: 16, color: color)),
    );
  }
}
