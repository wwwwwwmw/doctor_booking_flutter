import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/appointment_model.dart';
import 'package:doctor_booking_app/data/repositories/appointment_repository.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final availableSlotsProvider = FutureProvider.family<List<DateTime>, ({String doctorId, DateTime date})>((ref, params) {
  return ref.watch(appointmentRepositoryProvider).getAvailableSlots(params.doctorId, params.date);
});

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final String doctorId;
  final String doctorName;

  const BookAppointmentScreen({super.key, required this.doctorId, required this.doctorName});

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  DateTime _selectedSlot = DateTime.now();
  bool _slotSelected = false;
  String _consultationType = 'in_person';
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _bookAppointment() async {
    if (!_slotSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn giờ khám')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final appointment = AppointmentModel(
        id: '',
        patientId: userId,
        doctorId: widget.doctorId,
        bookingDate: _selectedSlot,
        startTime: _selectedSlot,
        endTime: _selectedSlot.add(const Duration(minutes: 30)),
        consultationType: _consultationType == 'video'
            ? ConsultationType.video
            : ConsultationType.inPerson,
        reason: _reasonController.text.isEmpty ? null : _reasonController.text,
        createdAt: DateTime.now(),
      );

      await ref.read(appointmentRepositoryProvider).createAppointment(appointment);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đặt lịch thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final slotsAsync = ref.watch(availableSlotsProvider((doctorId: widget.doctorId, date: selectedDate)));

    return Scaffold(
      appBar: AppBar(title: Text('Đặt lịch - ${widget.doctorName}')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar
            Container(
              decoration: AppDecorations.card,
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: selectedDate,
                selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                onDaySelected: (selected, focused) {
                  ref.read(selectedDateProvider.notifier).state = selected;
                  setState(() => _slotSelected = false);
                },
                calendarFormat: CalendarFormat.twoWeeks,
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                  todayTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            AppSpacing.gapXxl,

            // Consultation type
            const Text('Loại khám', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            AppSpacing.gapSm,
            Row(
              children: [
                Expanded(child: _TypeCard(
                  icon: Icons.person_rounded, label: 'Trực tiếp',
                  selected: _consultationType == 'in_person',
                  onTap: () => setState(() => _consultationType = 'in_person'),
                )),
                AppSpacing.gapHMd,
                Expanded(child: _TypeCard(
                  icon: Icons.videocam_rounded, label: 'Video Call',
                  selected: _consultationType == 'video',
                  onTap: () => setState(() => _consultationType = 'video'),
                )),
              ],
            ),
            AppSpacing.gapXxl,

            // Available slots
            const Text('Chọn giờ khám', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            AppSpacing.gapSm,
            slotsAsync.when(
              data: (slots) {
                if (slots.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: AppDecorations.cardFlat,
                    child: const Center(
                      child: Column(children: [
                        Icon(Icons.event_busy_rounded, size: 40, color: AppColors.textTertiary),
                        SizedBox(height: 8),
                        Text('Không có slot trống ngày này', style: TextStyle(color: AppColors.textSecondary)),
                      ]),
                    ),
                  );
                }
                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: slots.map((slot) {
                    final isSelected = _slotSelected && _selectedSlot == slot;
                    final timeStr = '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}';
                    return GestureDetector(
                      onTap: () => setState(() { _selectedSlot = slot; _slotSelected = true; }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        decoration: isSelected ? AppDecorations.cardSelected : AppDecorations.cardFlat,
                        child: Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.xxl), child: CircularProgressIndicator())),
              error: (e, _) => Text('Lỗi: $e', style: const TextStyle(color: AppColors.error)),
            ),
            AppSpacing.gapXxl,

            // Reason
            const Text('Lý do khám (tùy chọn)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            AppSpacing.gapSm,
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Mô tả triệu chứng hoặc lý do khám...',
              ),
            ),
            AppSpacing.gapXxxl,

            // Booking summary
            if (_slotSelected) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: AppDecorations.chipDecoration(AppColors.primary),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                    AppSpacing.gapHMd,
                    Expanded(
                      child: Text(
                        '${_consultationType == 'video' ? '📹 Video Call' : '🏥 Trực tiếp'} • '
                        '${_selectedSlot.hour.toString().padLeft(2, '0')}:${_selectedSlot.minute.toString().padLeft(2, '0')} '
                        '${_selectedSlot.day}/${_selectedSlot.month}/${_selectedSlot.year}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapLg,
            ],

            // Book button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _bookAppointment,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Xác nhận đặt lịch', style: TextStyle(fontSize: 16)),
              ),
            ),
            AppSpacing.gapLg,
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeCard({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: selected ? AppDecorations.cardSelected : AppDecorations.cardFlat,
        child: Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: AppDecorations.iconContainer(selected ? AppColors.primary : AppColors.textTertiary),
              child: Icon(icon, color: selected ? AppColors.primary : AppColors.textTertiary, size: 24),
            ),
            AppSpacing.gapSm,
            Text(label, style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            )),
          ],
        ),
      ),
    );
  }
}
