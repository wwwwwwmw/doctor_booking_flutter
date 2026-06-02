import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

class DoctorAnalyticsScreen extends StatelessWidget {
  const DoctorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'week', label: Text('Tuần')),
                ButtonSegment(value: 'month', label: Text('Tháng')),
                ButtonSegment(value: 'year', label: Text('Năm')),
              ],
              selected: const {'month'},
              onSelectionChanged: (_) {},
            ),
            AppSpacing.gapXxl,

            // Revenue card
            Container(
              decoration: AppDecorations.cardElevated,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Doanh thu tháng này', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  AppSpacing.gapXs,
                  const Text('38.400.000đ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.success)),
                  AppSpacing.gapXs,
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: AppDecorations.chipDecoration(AppColors.success),
                        child: const Text('+12%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                      ),
                      AppSpacing.gapHSm,
                      const Text('so với tháng trước', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    ],
                  ),
                  AppSpacing.gapXxl,
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 50,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                                return Text(days[value.toInt() % 7], style: const TextStyle(fontSize: 11, color: AppColors.textTertiary));
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (i) => BarChartGroupData(
                          x: i,
                          barRods: [BarChartRodData(
                            toY: [30, 25, 40, 35, 45, 20, 10][i].toDouble(),
                            gradient: AppColors.primaryGradient,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          )],
                        )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapXxl,

            // Stats grid
            Row(
              children: [
                Expanded(child: AppStatCard(icon: Icons.people_rounded, value: '128', label: 'Tổng bệnh nhân', color: AppColors.primary)),
                AppSpacing.gapHMd,
                Expanded(child: AppStatCard(icon: Icons.calendar_today_rounded, value: '256', label: 'Tổng lịch hẹn', color: AppColors.success)),
              ],
            ),
            AppSpacing.gapMd,
            Row(
              children: [
                Expanded(child: AppStatCard(icon: Icons.star_rounded, value: '4.8', label: 'Đánh giá TB', color: AppColors.accent)),
                AppSpacing.gapHMd,
                Expanded(child: AppStatCard(icon: Icons.videocam_rounded, value: '45', label: 'Video calls', color: AppColors.secondary)),
              ],
            ),
            AppSpacing.gapXxl,

            // Rating distribution
            Container(
              decoration: AppDecorations.cardElevated,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Phân bố đánh giá', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  AppSpacing.gapLg,
                  ...List.generate(5, (i) {
                    final star = 5 - i;
                    final percent = [60, 25, 10, 3, 2][i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          SizedBox(width: 20, child: Text('$star', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade700),
                          AppSpacing.gapHSm,
                          Expanded(
                            child: ClipRRect(
                              borderRadius: AppSpacing.borderRadiusRound,
                              child: LinearProgressIndicator(value: percent / 100, minHeight: 8,
                                backgroundColor: AppColors.surfaceVariant, color: Colors.amber.shade700),
                            ),
                          ),
                          AppSpacing.gapHSm,
                          SizedBox(width: 35, child: Text('$percent%', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.end)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            AppSpacing.gapXxl,

            // Appointment types pie chart
            Container(
              decoration: AppDecorations.cardElevated,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Loại khám', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  AppSpacing.gapLg,
                  SizedBox(
                    height: 180,
                    child: PieChart(PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(value: 65, title: '65%', color: AppColors.primary, radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        PieChartSectionData(value: 25, title: '25%', color: AppColors.success, radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        PieChartSectionData(value: 10, title: '10%', color: AppColors.accent, radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    )),
                  ),
                  AppSpacing.gapLg,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Legend(color: AppColors.primary, label: 'Trực tiếp'),
                      _Legend(color: AppColors.success, label: 'Video Call'),
                      _Legend(color: AppColors.accent, label: 'Tái khám'),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.gapXxxl,
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      AppSpacing.gapHSm,
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }
}
