import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/repositories/admin_repository.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';
import 'package:doctor_booking_app/presentation/admin/user_management/admin_user_management_screen.dart';
import 'package:doctor_booking_app/presentation/admin/doctor_approval/admin_doctor_approval_screen.dart';
import 'package:doctor_booking_app/presentation/common/auth/login_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentTab = 0;

  void switchTab(int index) {
    setState(() => _currentTab = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _DashboardOverview(ref: ref, onSwitchTab: switchTab),
      const AdminUserManagementScreen(),
      const AdminDoctorApprovalScreen(),
      _AdminSettingsTab(ref: ref, onSwitchTab: switchTab),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: switchTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Tổng quan'),
          NavigationDestination(icon: Icon(Icons.people_rounded), label: 'Người dùng'),
          NavigationDestination(icon: Icon(Icons.verified_user_rounded), label: 'Duyệt BS'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Cài đặt'),
        ],
      ),
    );
  }
}

// ==================== TAB 1: DASHBOARD OVERVIEW ====================

class _DashboardOverview extends StatelessWidget {
  final WidgetRef ref;
  final ValueChanged<int> onSwitchTab;
  const _DashboardOverview({required this.ref, required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);
    final weeklyAsync = ref.watch(weeklyStatsProvider);
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị hệ thống'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(adminStatsProvider);
              ref.invalidate(weeklyStatsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminStatsProvider);
          ref.invalidate(weeklyStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPaddingAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats grid
              statsAsync.when(
                data: (stats) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppStatCard(
                            icon: Icons.people_rounded,
                            value: formatter.format(stats.totalUsers),
                            label: 'Người dùng',
                            color: AppColors.primary,
                            gradient: AppColors.heroGradient,
                          ),
                        ),
                        AppSpacing.gapHMd,
                        Expanded(
                          child: AppStatCard(
                            icon: Icons.medical_services_rounded,
                            value: formatter.format(stats.totalDoctors),
                            label: 'Bác sĩ',
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms),
                    AppSpacing.gapMd,
                    Row(
                      children: [
                        Expanded(
                          child: AppStatCard(
                            icon: Icons.calendar_today_rounded,
                            value: formatter.format(stats.totalAppointments),
                            label: 'Lịch hẹn',
                            color: AppColors.accent,
                          ),
                        ),
                        AppSpacing.gapHMd,
                        Expanded(
                          child: AppStatCard(
                            icon: Icons.payments_rounded,
                            value: '${formatter.format(stats.totalRevenue.toInt())}đ',
                            label: 'Doanh thu',
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  ],
                ),
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: CircularProgressIndicator(),
                )),
                error: (e, _) => _ErrorCard(message: '$e', onRetry: () => ref.invalidate(adminStatsProvider)),
              ),
              AppSpacing.gapXxl,

              // Weekly chart
              const AppSectionHeader(title: 'Lịch hẹn 7 ngày gần nhất'),
              AppSpacing.gapMd,
              weeklyAsync.when(
                data: (weeklyData) => Container(
                  height: 200,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: AppDecorations.card,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (weeklyData.map((e) => e.count).fold(0, (a, b) => a > b ? a : b) + 2).toDouble(),
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                weeklyData[value.toInt()].dayLabel,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textTertiary),
                              ),
                            ),
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: weeklyData.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.count.toDouble(),
                              color: AppColors.primary,
                              width: 18,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                loading: () => const AppShimmerLoading(height: 200),
                error: (e, _) => _ErrorCard(message: '$e', onRetry: () => ref.invalidate(weeklyStatsProvider)),
              ),
              AppSpacing.gapXxl,

              // Quick actions
              const AppSectionHeader(title: 'Thao tác nhanh'),
              AppSpacing.gapMd,
              statsAsync.when(
                data: (stats) => Column(
                  children: [
                    if (stats.pendingDoctors > 0)
                      _QuickActionCard(
                        icon: Icons.person_add_rounded,
                        title: '${stats.pendingDoctors} bác sĩ chờ duyệt',
                        subtitle: 'Xem và duyệt hồ sơ bác sĩ mới',
                        color: AppColors.statusPending,
                        onTap: () => onSwitchTab(2),
                      ),
                    _QuickActionCard(
                      icon: Icons.today_rounded,
                      title: '${stats.todayAppointments} lịch hẹn hôm nay',
                      subtitle: 'Xem lịch hẹn trong ngày',
                      color: AppColors.primary,
                      onTap: () {},
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              AppSpacing.gapXxxl,
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== TAB 4: ADMIN SETTINGS ====================

class _AdminSettingsTab extends StatelessWidget {
  final WidgetRef ref;
  final ValueChanged<int> onSwitchTab;
  const _AdminSettingsTab({required this.ref, required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt Admin')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          _SettingsSection(title: 'QUẢN LÝ', children: [
            _SettingsTile(icon: Icons.people_outline, color: AppColors.primary, title: 'Quản lý người dùng', onTap: () => onSwitchTab(1)),
            _SettingsTile(icon: Icons.verified_user_outlined, color: AppColors.success, title: 'Duyệt bác sĩ', onTap: () => onSwitchTab(2)),
          ]),
          _SettingsSection(title: 'HỆ THỐNG', children: [
            _SettingsTile(icon: Icons.language_rounded, color: AppColors.secondary, title: 'Ngôn ngữ', trailing: 'Tiếng Việt', onTap: () {}),
            _SettingsTile(icon: Icons.dark_mode_rounded, color: AppColors.textSecondary, title: 'Giao diện', trailing: 'Theo hệ thống', onTap: () {}),
            _SettingsTile(icon: Icons.info_outline_rounded, color: AppColors.textTertiary, title: 'Phiên bản', trailing: '1.0.0', onTap: () {}),
          ]),
          _SettingsSection(title: 'TÀI KHOẢN', children: [
            _SettingsTile(
              icon: Icons.logout_rounded,
              color: AppColors.error,
              title: 'Đăng xuất',
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Đăng xuất?'),
                    content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await Supabase.instance.client.auth.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (r) => false,
                  );
                }
              },
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: const Text('Doctor Booking Admin v1.0.0', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          ),
        ],
      ),
    );
  }
}

// ==================== HELPER WIDGETS ====================

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: AppDecorations.iconContainer(color),
                  child: Icon(icon, color: color, size: 22),
                ),
                AppSpacing.gapHMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      AppSpacing.gapXs,
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          AppSpacing.gapHMd,
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13, color: AppColors.error))),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
        child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.8)),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: AppDecorations.cardFlat,
        child: Column(children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) AppDecorations.thinDivider,
          ],
        ]),
      ),
    ]);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.color, required this.title, this.trailing, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(children: [
            Container(width: 32, height: 32, decoration: AppDecorations.iconContainer(color), child: Icon(icon, size: 16, color: color)),
            AppSpacing.gapHMd,
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            if (trailing != null) Text(trailing!, style: const TextStyle(fontSize: 13, color: AppColors.textTertiary)),
            AppSpacing.gapHSm,
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
          ]),
        ),
      ),
    );
  }
}
