import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/appointment_model.dart';
import 'package:doctor_booking_app/data/repositories/appointment_repository.dart';
import 'package:doctor_booking_app/presentation/common/notifications/notifications_screen.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';
import 'package:doctor_booking_app/presentation/doctor/calendar/doctor_calendar_screen.dart';
import 'package:doctor_booking_app/presentation/doctor/patients/doctor_patients_screen.dart';
import 'package:doctor_booking_app/presentation/doctor/profile/doctor_profile_screen.dart';
import 'package:doctor_booking_app/presentation/doctor/analytics/doctor_analytics_screen.dart';
import 'package:doctor_booking_app/presentation/doctor/settings/doctor_settings_screen.dart';
import 'package:doctor_booking_app/presentation/chat/chat_inbox_screen.dart';
import 'package:doctor_booking_app/presentation/telemedicine/waiting_room_screen.dart';

/// Doctor's appointments provider — real data from DB
final doctorAppointmentsProvider = FutureProvider<List<AppointmentModel>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  return ref.watch(appointmentRepositoryProvider).getDoctorAppointments(userId);
});

class DoctorHomeScreen extends ConsumerStatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  ConsumerState<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends ConsumerState<DoctorHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _DoctorDashboard(),
      const DoctorCalendarScreen(),
      const DoctorPatientsScreen(),
      const DoctorProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Tổng quan'),
            NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Lịch hẹn'),
            NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Bệnh nhân'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Hồ sơ'),
          ],
        ),
      ),
    );
  }
}

class _DoctorDashboard extends ConsumerWidget {
  const _DoctorDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final doctorName = user?.userMetadata?['full_name'] ?? 'Bác sĩ';
    final appointmentsAsync = ref.watch(doctorAppointmentsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(doctorAppointmentsProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Gradient header
            SliverToBoxAdapter(
              child: AppGradientHeader(
                greeting: 'Xin chào, BS. $doctorName 👋',
                title: 'Dashboard',
                subtitle: 'Quản lý lịch hẹn của bạn',
                showAvatar: false,
                actions: [
                  _headerBtn(Icons.notifications_outlined, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                  }),
                  AppSpacing.gapHSm,
                  _headerBtn(Icons.analytics_outlined, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorAnalyticsScreen()));
                  }),
                  AppSpacing.gapHSm,
                  _headerBtn(Icons.settings_outlined, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorSettingsScreen()));
                  }),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: appointmentsAsync.when(
                  data: (appointments) {
                    final today = DateTime.now();
                    final todayAppointments = appointments.where((a) =>
                        a.startTime.year == today.year &&
                        a.startTime.month == today.month &&
                        a.startTime.day == today.day).toList();
                    final pendingCount = appointments.where((a) => a.isPending).length;
                    final totalCount = appointments.length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats cards — real data
                        Row(
                          children: [
                            Expanded(
                              child: AppStatCard(
                                icon: Icons.calendar_today,
                                value: '${todayAppointments.length}',
                                label: 'Hôm nay',
                                color: AppColors.primary,
                                gradient: AppColors.primaryGradient,
                              ),
                            ),
                            AppSpacing.gapHMd,
                            Expanded(
                              child: AppStatCard(
                                icon: Icons.pending_actions,
                                value: '$pendingCount',
                                label: 'Chờ duyệt',
                                color: AppColors.accent,
                              ),
                            ),
                            AppSpacing.gapHMd,
                            Expanded(
                              child: AppStatCard(
                                icon: Icons.check_circle_outline,
                                value: '$totalCount',
                                label: 'Tổng',
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms),
                        AppSpacing.gapXxl,

                        // Today's appointments — real data
                        const AppSectionHeader(title: 'Lịch hẹn hôm nay'),
                        AppSpacing.gapMd,
                        if (todayAppointments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                            child: AppEmptyState(
                              icon: Icons.event_available_rounded,
                              title: 'Không có lịch hẹn hôm nay',
                              subtitle: 'Bạn chưa có lịch hẹn nào trong ngày hôm nay',
                            ),
                          )
                        else
                          ...todayAppointments.asMap().entries.map((entry) {
                            final apt = entry.value;
                            return _AppointmentCard(
                              appointment: apt,
                              index: entry.key,
                              onConfirm: () async {
                                await ref.read(appointmentRepositoryProvider).updateStatus(
                                  apt.id, AppointmentStatus.confirmed,
                                );
                                ref.invalidate(doctorAppointmentsProvider);
                              },
                              onReject: () async {
                                await ref.read(appointmentRepositoryProvider).updateStatus(
                                  apt.id, AppointmentStatus.cancelled,
                                );
                                ref.invalidate(doctorAppointmentsProvider);
                              },
                            );
                          }),
                        AppSpacing.gapXxl,

                        // Quick actions
                        const AppSectionHeader(title: 'Thao tác nhanh'),
                        AppSpacing.gapMd,
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: [
                            _QuickChip(
                              icon: Icons.schedule,
                              label: 'Cập nhật lịch',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorCalendarScreen())),
                            ),
                            _QuickChip(
                              icon: Icons.videocam_rounded,
                              label: 'Video Call',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WaitingRoomScreen(doctorName: 'Bác sĩ', channelName: 'video_call'))),
                            ),
                            _QuickChip(
                              icon: Icons.chat_rounded,
                              label: 'Tin nhắn',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatInboxScreen())),
                            ),
                            _QuickChip(
                              icon: Icons.analytics_rounded,
                              label: 'Thống kê',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorAnalyticsScreen())),
                            ),
                          ],
                        ).animate().fadeIn(delay: 300.ms),
                        AppSpacing.gapXxxl,
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => AppEmptyState(
                    icon: Icons.error_outline,
                    title: 'Không tải được dữ liệu',
                    subtitle: '$e',
                    actionText: 'Thử lại',
                    onAction: () => ref.invalidate(doctorAppointmentsProvider),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerBtn(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final int index;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const _AppointmentCard({
    required this.appointment,
    required this.index,
    required this.onConfirm,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: AppDecorations.card,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: AppDecorations.iconContainer(appointment.isVideo ? AppColors.success : AppColors.primary),
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
                    appointment.patientName ?? 'Bệnh nhân',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  AppSpacing.gapXs,
                  Text(
                    '${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')} • ${appointment.isVideo ? 'Video Call' : 'Trực tiếp'}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (appointment.isPending)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _miniBtn(Icons.check_rounded, AppColors.success, onConfirm),
                  AppSpacing.gapHSm,
                  _miniBtn(Icons.close_rounded, AppColors.error, onReject),
                ],
              )
            else
              Container(
                padding: AppSpacing.chipPadding,
                decoration: AppDecorations.statusBadge(appointment.status.name),
                child: Text(
                  appointment.isConfirmed ? 'Đã xác nhận' : appointment.status.name,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.statusConfirmed),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 80));
  }

  Widget _miniBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: AppDecorations.iconContainer(color),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusRound,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: AppDecorations.cardFlat,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              AppSpacing.gapHSm,
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
