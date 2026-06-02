import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

class DoctorCalendarScreen extends StatefulWidget {
  const DoctorCalendarScreen({super.key});

  @override
  State<DoctorCalendarScreen> createState() => _DoctorCalendarScreenState();
}

class _DoctorCalendarScreenState extends State<DoctorCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final _mockAppointments = <String, List<Map<String, String>>>{};

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final key = '${today.year}-${today.month}-${today.day}';
    _mockAppointments[key] = [
      {'time': '08:00 - 08:30', 'patient': 'Nguyễn Văn A', 'type': 'in_person', 'status': 'confirmed'},
      {'time': '09:00 - 09:30', 'patient': 'Trần Thị B', 'type': 'video', 'status': 'confirmed'},
      {'time': '10:30 - 11:00', 'patient': 'Lê Văn C', 'type': 'in_person', 'status': 'pending'},
      {'time': '14:00 - 14:30', 'patient': 'Phạm Thị D', 'type': 'in_person', 'status': 'confirmed'},
      {'time': '15:00 - 15:30', 'patient': 'Hoàng Văn E', 'type': 'video', 'status': 'pending'},
    ];
  }

  List<Map<String, String>> _getAppointmentsForDay(DateTime day) {
    final key = '${day.year}-${day.month}-${day.day}';
    return _mockAppointments[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final dayAppointments = _getAppointmentsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch làm việc'),
        actions: [
          IconButton(icon: const Icon(Icons.today_rounded), onPressed: () => setState(() {
            _focusedDay = DateTime.now();
            _selectedDay = DateTime.now();
          })),
          IconButton(icon: const Icon(Icons.edit_calendar_rounded), onPressed: () => _showEditScheduleSheet(context)),
        ],
      ),
      body: Column(
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
              eventLoader: (day) => _getAppointmentsForDay(day),
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
                ? const AppEmptyState(icon: Icons.event_available_rounded, title: 'Không có lịch hẹn')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: dayAppointments.length,
                    itemBuilder: (context, index) {
                      final apt = dayAppointments[index];
                      final isVideo = apt['type'] == 'video';
                      final isPending = apt['status'] == 'pending';

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
                                  color: isPending ? AppColors.statusPending : AppColors.statusConfirmed,
                                  borderRadius: AppSpacing.borderRadiusRound,
                                ),
                              ),
                              AppSpacing.gapHMd,
                              Container(
                                width: 40, height: 40,
                                decoration: AppDecorations.iconContainer(isVideo ? AppColors.success : AppColors.primary),
                                child: Icon(isVideo ? Icons.videocam_rounded : Icons.person_rounded, color: isVideo ? AppColors.success : AppColors.primary, size: 20),
                              ),
                              AppSpacing.gapHMd,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(apt['patient']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                    AppSpacing.gapXs,
                                    Text('${apt['time']} • ${isVideo ? 'Video' : 'Trực tiếp'}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              if (isPending) ...[
                                _miniBtn(Icons.check_rounded, AppColors.success, () {}),
                                AppSpacing.gapHSm,
                                _miniBtn(Icons.close_rounded, AppColors.error, () {}),
                              ] else if (isVideo)
                                FilledButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.videocam_rounded, size: 16),
                                  label: const Text('Gọi'),
                                  style: FilledButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(horizontal: 12)),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _miniBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 32, height: 32, decoration: AppDecorations.iconContainer(color), child: Icon(icon, size: 16, color: color)),
    );
  }

  void _showEditScheduleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: AppSpacing.borderRadiusRound))),
              AppSpacing.gapLg,
              const Text('Cài đặt giờ làm việc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              AppSpacing.gapLg,
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'].map((day) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: AppDecorations.cardFlat,
                      child: SwitchListTile(
                        title: Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: const Text('08:00 - 17:00', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        value: day != 'Chủ nhật',
                        onChanged: (v) {},
                        activeTrackColor: AppColors.primary,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
