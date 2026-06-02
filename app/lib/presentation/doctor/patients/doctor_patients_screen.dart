import 'package:flutter/material.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  String _searchQuery = '';

  final _mockPatients = [
    {'name': 'Nguyễn Văn A', 'age': '32', 'lastVisit': '10/05/2026', 'visits': '5', 'phone': '0901234567'},
    {'name': 'Trần Thị B', 'age': '28', 'lastVisit': '08/05/2026', 'visits': '3', 'phone': '0912345678'},
    {'name': 'Lê Văn C', 'age': '45', 'lastVisit': '05/05/2026', 'visits': '8', 'phone': '0923456789'},
    {'name': 'Phạm Thị D', 'age': '55', 'lastVisit': '01/05/2026', 'visits': '12', 'phone': '0934567890'},
    {'name': 'Hoàng Văn E', 'age': '38', 'lastVisit': '28/04/2026', 'visits': '2', 'phone': '0945678901'},
    {'name': 'Vũ Thị F', 'age': '22', 'lastVisit': '25/04/2026', 'visits': '1', 'phone': '0956789012'},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? _mockPatients
        : _mockPatients.where((p) => p['name']!.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Bệnh nhân')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppSearchBar(
              hint: 'Tìm bệnh nhân...',
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: AppSpacing.chipPadding,
                  decoration: AppDecorations.chipDecoration(AppColors.primary),
                  child: Text('${filtered.length} bệnh nhân', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
                ),
                const Spacer(),
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.sort_rounded, size: 16), label: const Text('Sắp xếp')),
              ],
            ),
          ),
          AppSpacing.gapSm,
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final patient = filtered[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: AppDecorations.card,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showPatientDetail(context, patient),
                      borderRadius: AppSpacing.borderRadiusLg,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(borderRadius: AppSpacing.borderRadiusMd, color: AppColors.primarySurface),
                              child: Center(child: Text(patient['name']![0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary))),
                            ),
                            AppSpacing.gapHMd,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(patient['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  AppSpacing.gapXs,
                                  Text('${patient['age']} tuổi • Gần nhất: ${patient['lastVisit']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(patient['visits']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                const Text('lần', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  void _showPatientDetail(BuildContext context, Map<String, String> patient) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7, expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ListView(
            controller: controller,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: AppSpacing.borderRadiusRound))),
              AppSpacing.gapXxl,
              Center(child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primarySurface),
                child: Center(child: Text(patient['name']![0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.primary))),
              )),
              AppSpacing.gapMd,
              Center(child: Text(patient['name']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
              Center(child: Text('${patient['age']} tuổi • ${patient['phone']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
              AppSpacing.gapXxl,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionBtn(icon: Icons.chat_rounded, label: 'Chat', color: AppColors.primary, onTap: () {}),
                  _ActionBtn(icon: Icons.videocam_rounded, label: 'Video', color: AppColors.success, onTap: () {}),
                  _ActionBtn(icon: Icons.note_add_rounded, label: 'Ghi chú', color: AppColors.accent, onTap: () {}),
                  _ActionBtn(icon: Icons.folder_rounded, label: 'Hồ sơ', color: AppColors.secondary, onTap: () {}),
                ],
              ),
              AppSpacing.gapXxl,
              const Text('Lịch sử khám', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              AppSpacing.gapMd,
              ...List.generate(3, (i) => Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: AppDecorations.cardFlat,
                child: ListTile(
                  leading: Container(
                    width: 36, height: 36,
                    decoration: AppDecorations.iconContainer(AppColors.primary),
                    child: const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 18),
                  ),
                  title: const Text('Khám tổng quát', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text('${10 - i * 5}/05/2026', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusLg,
      child: Column(
        children: [
          Container(width: 48, height: 48, decoration: AppDecorations.iconContainer(color, radius: 14), child: Icon(icon, color: color, size: 22)),
          AppSpacing.gapSm,
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
