import 'package:flutter/material.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  String _filter = 'all';
  String _search = '';

  final _mockUsers = [
    {'name': 'Nguyễn Văn A', 'email': 'a@gmail.com', 'role': 'patient', 'active': true, 'date': '01/01/2026'},
    {'name': 'Trần Thị B', 'email': 'b@gmail.com', 'role': 'patient', 'active': true, 'date': '15/02/2026'},
    {'name': 'BS. Lê Văn C', 'email': 'c@gmail.com', 'role': 'doctor', 'active': true, 'date': '10/03/2026'},
    {'name': 'Phạm Thị D', 'email': 'd@gmail.com', 'role': 'patient', 'active': false, 'date': '20/04/2026'},
    {'name': 'BS. Hoàng Văn E', 'email': 'e@gmail.com', 'role': 'doctor', 'active': true, 'date': '05/05/2026'},
    {'name': 'Admin', 'email': 'admin@doctorbooking.vn', 'role': 'admin', 'active': true, 'date': '01/01/2025'},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _mockUsers.where((u) {
      if (_filter != 'all' && u['role'] != _filter) return false;
      if (_search.isNotEmpty && !(u['name'] as String).toLowerCase().contains(_search.toLowerCase())) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý người dùng')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppSearchBar(
            hint: 'Tìm kiếm...',
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(children: [
            FilterChip(label: Text('Tất cả (${_mockUsers.length})'), selected: _filter == 'all',
              onSelected: (_) => setState(() => _filter = 'all')),
            AppSpacing.gapHSm,
            FilterChip(label: const Text('Bệnh nhân'), selected: _filter == 'patient',
              onSelected: (_) => setState(() => _filter = _filter == 'patient' ? 'all' : 'patient')),
            AppSpacing.gapHSm,
            FilterChip(label: const Text('Bác sĩ'), selected: _filter == 'doctor',
              onSelected: (_) => setState(() => _filter = _filter == 'doctor' ? 'all' : 'doctor')),
            AppSpacing.gapHSm,
            FilterChip(label: const Text('Admin'), selected: _filter == 'admin',
              onSelected: (_) => setState(() => _filter = _filter == 'admin' ? 'all' : 'admin')),
          ]),
        ),
        AppSpacing.gapSm,
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final user = filtered[index];
            final roleColor = switch (user['role']) {
              'doctor' => AppColors.success, 'admin' => AppColors.secondary, _ => AppColors.primary,
            };
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: AppDecorations.card,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: AppDecorations.iconContainer(roleColor),
                      child: Icon(
                        switch (user['role']) { 'doctor' => Icons.medical_services_rounded, 'admin' => Icons.admin_panel_settings_rounded, _ => Icons.person_rounded },
                        color: roleColor, size: 22,
                      ),
                    ),
                    AppSpacing.gapHMd,
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(user['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: AppDecorations.chipDecoration(roleColor),
                          child: Text(
                            switch (user['role']) { 'doctor' => 'Bác sĩ', 'admin' => 'Admin', _ => 'Bệnh nhân' },
                            style: TextStyle(fontSize: 10, color: roleColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ]),
                      AppSpacing.gapXs,
                      Text('${user['email']} • ${user['date']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ])),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textTertiary),
                      itemBuilder: (_) => [
                        const PopupMenuItem(child: ListTile(dense: true, leading: Icon(Icons.edit_rounded), title: Text('Sửa'))),
                        PopupMenuItem(child: ListTile(dense: true,
                          leading: Icon((user['active'] as bool) ? Icons.block_rounded : Icons.check_circle_rounded),
                          title: Text((user['active'] as bool) ? 'Khóa' : 'Mở khóa'))),
                        const PopupMenuItem(child: ListTile(dense: true,
                          leading: Icon(Icons.delete_rounded, color: AppColors.error),
                          title: Text('Xóa', style: TextStyle(color: AppColors.error)))),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        )),
      ]),
    );
  }
}
