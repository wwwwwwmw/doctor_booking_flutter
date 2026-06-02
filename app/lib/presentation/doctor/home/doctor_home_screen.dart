import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/presentation/common/notifications/notifications_screen.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';
import 'package:doctor_booking_app/presentation/doctor/calendar/doctor_calendar_screen.dart';
import 'package:doctor_booking_app/presentation/doctor/patients/doctor_patients_screen.dart';
import 'package:doctor_booking_app/presentation/doctor/profile/doctor_profile_screen.dart';
import 'package:doctor_booking_app/presentation/doctor/analytics/doctor_analytics_screen.dart';
import 'package:doctor_booking_app/presentation/doctor/settings/doctor_settings_screen.dart';
import 'package:doctor_booking_app/presentation/chat/chat_inbox_screen.dart';
import 'package:doctor_booking_app/presentation/telemedicine/waiting_room_screen.dart';

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

class _DoctorDashboard extends StatelessWidget {
  const _DoctorDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient header
          SliverToBoxAdapter(
            child: AppGradientHeader(
              greeting: 'Xin chào, Bác sĩ 👋',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats cards
                  Row(
                    children: [
                      Expanded(
                        child: AppStatCard(
                          icon: Icons.calendar_today,
                          value: '12',
                          label: 'Hôm nay',
                          color: AppColors.primary,
                          gradient: AppColors.primaryGradient,
                        ),
                      ),
                      AppSpacing.gapHMd,
                      Expanded(
                        child: AppStatCard(
                          icon: Icons.pending_actions,
                          value: '5',
                          label: 'Chờ duyệt',
                          color: AppColors.accent,
                        ),
                      ),
                      AppSpacing.gapHMd,
                      Expanded(
                        child: AppStatCard(
                          icon: Icons.check_circle_outline,
                          value: '128',
                          label: 'Tổng',
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
                  AppSpacing.gapXxl,

                  // Today's appointments
                  const AppSectionHeader(title: 'Lịch hẹn hôm nay'),
                  AppSpacing.gapMd,
                  ..._buildTodayAppointments(context),
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
              ),
            ),
          ),
        ],
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

  List<Widget> _buildTodayAppointments(BuildContext context) {
    final appointments = [
      {'time': '08:00', 'patient': 'Nguyễn Văn A', 'type': 'Khám tổng quát', 'status': 'confirmed'},
      {'time': '09:00', 'patient': 'Trần Thị B', 'type': 'Tái khám', 'status': 'confirmed'},
      {'time': '10:30', 'patient': 'Lê Văn C', 'type': 'Video Call', 'status': 'pending'},
      {'time': '14:00', 'patient': 'Phạm Thị D', 'type': 'Khám chuyên khoa', 'status': 'confirmed'},
    ];

    return appointments.asMap().entries.map((entry) {
      final apt = entry.value;
      final isVideo = apt['type'] == 'Video Call';
      final isPending = apt['status'] == 'pending';
      final statusColor = isPending ? AppColors.statusPending : AppColors.statusConfirmed;

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: AppDecorations.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: AppDecorations.iconContainer(isVideo ? AppColors.success : AppColors.primary),
                child: Icon(isVideo ? Icons.videocam_rounded : Icons.person_rounded, color: isVideo ? AppColors.success : AppColors.primary, size: 22),
              ),
              AppSpacing.gapHMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(apt['patient']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    AppSpacing.gapXs,
                    Text('${apt['time']} • ${apt['type']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (isPending)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _miniBtn(Icons.check_rounded, AppColors.success, () {}),
                    AppSpacing.gapHSm,
                    _miniBtn(Icons.close_rounded, AppColors.error, () {}),
                  ],
                )
              else
                Container(
                  padding: AppSpacing.chipPadding,
                  decoration: AppDecorations.statusBadge('confirmed'),
                  child: Text('Đã xác nhận', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 100 + entry.key * 80));
    }).toList();
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
