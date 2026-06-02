import 'package:flutter/material.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';

class AdminDoctorApprovalScreen extends StatelessWidget {
  const AdminDoctorApprovalScreen({super.key});

  static const _pendingDoctors = [
    {'name': 'BS. Nguyễn Minh Tuấn', 'speciality': 'Tim mạch', 'hospital': 'BV Chợ Rẫy', 'exp': '8 năm', 'date': '15/05/2026'},
    {'name': 'BS. Trần Thu Hà', 'speciality': 'Nhi khoa', 'hospital': 'BV Nhi Đồng 1', 'exp': '5 năm', 'date': '14/05/2026'},
    {'name': 'BS. Lê Quang Huy', 'speciality': 'Da liễu', 'hospital': 'BV Da liễu', 'exp': '12 năm', 'date': '13/05/2026'},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Duyệt bác sĩ'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Chờ duyệt (3)'),
            Tab(text: 'Đã duyệt'),
            Tab(text: 'Từ chối'),
          ]),
        ),
        body: TabBarView(children: [
          // Pending tab
          ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: _pendingDoctors.length,
            itemBuilder: (context, index) {
              final doc = _pendingDoctors[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: AppDecorations.card,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(borderRadius: AppSpacing.borderRadiusMd, color: AppColors.primarySurface),
                      child: Center(child: Text(doc['name']![4], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary))),
                    ),
                    AppSpacing.gapHMd,
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(doc['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      AppSpacing.gapXs,
                      Text('${doc['speciality']} • ${doc['exp']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(doc['hospital']!, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    ])),
                  ]),
                  AppSpacing.gapLg,
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.description_rounded, size: 16), label: const Text('Xem hồ sơ'))),
                    AppSpacing.gapHSm,
                    Expanded(child: FilledButton.icon(
                      onPressed: () => _showApproveDialog(context, doc['name']!),
                      icon: const Icon(Icons.check_rounded, size: 16), label: const Text('Duyệt'),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.success))),
                    AppSpacing.gapHSm,
                    Container(
                      width: 40, height: 40,
                      decoration: AppDecorations.iconContainer(AppColors.error),
                      child: IconButton(onPressed: () {}, icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 18), padding: EdgeInsets.zero),
                    ),
                  ]),
                ]),
              );
            },
          ),
          // Approved tab
          const Center(child: Text('Danh sách bác sĩ đã duyệt', style: TextStyle(color: AppColors.textSecondary))),
          // Rejected tab
          const Center(child: Text('Danh sách bác sĩ bị từ chối', style: TextStyle(color: AppColors.textSecondary))),
        ]),
      ),
    );
  }

  void _showApproveDialog(BuildContext context, String name) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Xác nhận duyệt'),
      content: Text('Bạn muốn duyệt $name trở thành bác sĩ chính thức?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        FilledButton(onPressed: () { Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Đã duyệt $name'), backgroundColor: AppColors.success));
        }, child: const Text('Duyệt')),
      ],
    ));
  }
}
