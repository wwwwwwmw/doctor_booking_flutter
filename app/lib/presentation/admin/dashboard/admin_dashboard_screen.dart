import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/presentation/admin/doctor_approval/admin_doctor_approval_screen.dart';
import 'package:doctor_booking_app/presentation/admin/user_management/admin_user_management_screen.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), actions: [
        IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
      ]),
      drawer: Drawer(
        child: ListView(children: [
          DrawerHeader(
            decoration: const BoxDecoration(gradient: AppColors.heroGradient),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(Icons.admin_panel_settings_rounded, size: 28, color: Colors.white),
              ),
              AppSpacing.gapSm,
              const Text('Admin Panel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              const Text('admin@doctorbooking.vn', style: TextStyle(fontSize: 12, color: Colors.white70)),
            ]),
          ),
          _DrawerItem(icon: Icons.dashboard_rounded, title: 'Tổng quan', selected: true, onTap: () => Navigator.pop(context)),
          _DrawerItem(icon: Icons.verified_user_rounded, title: 'Duyệt bác sĩ', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDoctorApprovalScreen())); }),
          _DrawerItem(icon: Icons.people_rounded, title: 'Quản lý người dùng', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserManagementScreen())); }),
          _DrawerItem(icon: Icons.local_hospital_rounded, title: 'Chuyên khoa', onTap: () {}),
          _DrawerItem(icon: Icons.calendar_today_rounded, title: 'Lịch hẹn', onTap: () {}),
          _DrawerItem(icon: Icons.payment_rounded, title: 'Thanh toán', onTap: () {}),
          AppDecorations.thinDivider,
          _DrawerItem(icon: Icons.settings_rounded, title: 'Cài đặt hệ thống', onTap: () {}),
          _DrawerItem(icon: Icons.logout_rounded, title: 'Đăng xuất', color: AppColors.error, onTap: () {}),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats grid
            Row(children: [
              Expanded(child: _AdminStat(icon: Icons.people_rounded, value: '1,234', label: 'Tổng người dùng', color: AppColors.primary, trend: '+12%')),
              AppSpacing.gapHMd,
              Expanded(child: _AdminStat(icon: Icons.medical_services_rounded, value: '56', label: 'Bác sĩ', color: AppColors.success, trend: '+3')),
            ]),
            AppSpacing.gapMd,
            Row(children: [
              Expanded(child: _AdminStat(icon: Icons.calendar_today_rounded, value: '2,456', label: 'Lịch hẹn', color: AppColors.accent, trend: '+8%')),
              AppSpacing.gapHMd,
              Expanded(child: _AdminStat(icon: Icons.monetization_on_rounded, value: '125M', label: 'Doanh thu', color: AppColors.secondary, trend: '+15%')),
            ]),
            AppSpacing.gapXxl,

            // Chart
            Container(
              decoration: AppDecorations.cardElevated,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lịch hẹn theo tuần', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  AppSpacing.gapLg,
                  SizedBox(height: 200, child: LineChart(LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                        final labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                        return Text(labels[v.toInt() % 7], style: const TextStyle(fontSize: 11, color: AppColors.textTertiary));
                      })),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [LineChartBarData(
                      spots: const [FlSpot(0,30), FlSpot(1,45), FlSpot(2,38), FlSpot(3,50), FlSpot(4,42), FlSpot(5,25), FlSpot(6,15)],
                      isCurved: true, color: AppColors.primary, barWidth: 3, dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1)),
                    )],
                  ))),
                ],
              ),
            ),
            AppSpacing.gapXxl,

            // Pending actions
            const AppSectionHeader(title: 'Cần xử lý'),
            AppSpacing.gapMd,
            _ActionCard(icon: Icons.person_add_rounded, color: AppColors.accent, title: '3 bác sĩ chờ duyệt', onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDoctorApprovalScreen()))),
            AppSpacing.gapSm,
            _ActionCard(icon: Icons.report_rounded, color: AppColors.error, title: '2 báo cáo vi phạm', onTap: () {}),
            AppSpacing.gapSm,
            _ActionCard(icon: Icons.feedback_rounded, color: AppColors.primary, title: '5 phản hồi mới', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;
  const _DrawerItem({required this.icon, required this.title, this.selected = false, this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = color ?? (selected ? AppColors.primary : AppColors.textPrimary);
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(title, style: TextStyle(color: c, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
      selected: selected,
      selectedTileColor: AppColors.primarySurface,
      onTap: onTap,
    );
  }
}

class _AdminStat extends StatelessWidget {
  final IconData icon; final String value, label, trend; final Color color;
  const _AdminStat({required this.icon, required this.value, required this.label, required this.color, required this.trend});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.card,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32, decoration: AppDecorations.iconContainer(color), child: Icon(icon, color: color, size: 16)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: AppDecorations.chipDecoration(AppColors.success),
            child: Text(trend, style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ]),
        AppSpacing.gapSm,
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
      ]),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final Color color; final String title; final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.color, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: AppDecorations.iconContainer(color), child: Icon(icon, color: color, size: 22)),
              AppSpacing.gapHMd,
              Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
              FilledButton(onPressed: onTap, child: const Text('Xem')),
            ]),
          ),
        ),
      ),
    );
  }
}
