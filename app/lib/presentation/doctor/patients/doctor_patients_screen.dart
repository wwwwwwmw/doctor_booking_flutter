import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';
import 'package:doctor_booking_app/presentation/chat/chat_inbox_screen.dart';

/// Model for a patient summary (from appointments)
class _PatientSummary {
  final String id;
  final String name;
  final String? avatarUrl;
  final int visitCount;
  final DateTime? lastVisit;

  const _PatientSummary({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.visitCount,
    this.lastVisit,
  });
}

/// Provider: load unique patients from doctor's appointments
final doctorPatientsProvider = FutureProvider<List<_PatientSummary>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  final client = Supabase.instance.client;

  // Get all appointments for this doctor with patient info
  final data = await client
      .from('appointments')
      .select('patient_id, start_time, patient:users!appointments_patient_id_fkey(full_name, avatar_url)')
      .eq('doctor_id', userId)
      .order('start_time', ascending: false);

  // Group by patient_id
  final patientMap = <String, _PatientSummary>{};
  for (final row in (data as List)) {
    final pid = row['patient_id'] as String;
    final patient = row['patient'] as Map<String, dynamic>?;
    final name = patient?['full_name'] as String? ?? 'Bệnh nhân';
    final avatar = patient?['avatar_url'] as String?;
    final visitTime = DateTime.tryParse(row['start_time'] as String? ?? '');

    if (patientMap.containsKey(pid)) {
      final existing = patientMap[pid]!;
      patientMap[pid] = _PatientSummary(
        id: pid,
        name: name,
        avatarUrl: avatar,
        visitCount: existing.visitCount + 1,
        lastVisit: existing.lastVisit,
      );
    } else {
      patientMap[pid] = _PatientSummary(
        id: pid,
        name: name,
        avatarUrl: avatar,
        visitCount: 1,
        lastVisit: visitTime,
      );
    }
  }

  return patientMap.values.toList();
});

class DoctorPatientsScreen extends ConsumerStatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  ConsumerState<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends ConsumerState<DoctorPatientsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(doctorPatientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bệnh nhân')),
      body: patientsAsync.when(
        data: (patients) {
          final filtered = _searchQuery.isEmpty
              ? patients
              : patients.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

          return Column(
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
                  ],
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: filtered.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.people_outline,
                        title: 'Chưa có bệnh nhân',
                        subtitle: 'Danh sách bệnh nhân sẽ hiển thị khi có lịch hẹn',
                      )
                    : ListView.builder(
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
                                        decoration: BoxDecoration(
                                          borderRadius: AppSpacing.borderRadiusMd,
                                          color: AppColors.primarySurface,
                                          image: patient.avatarUrl != null
                                              ? DecorationImage(image: NetworkImage(patient.avatarUrl!), fit: BoxFit.cover)
                                              : null,
                                        ),
                                        child: patient.avatarUrl == null
                                            ? Center(child: Text(patient.name.isNotEmpty ? patient.name[0] : '?', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary)))
                                            : null,
                                      ),
                                      AppSpacing.gapHMd,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(patient.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                            AppSpacing.gapXs,
                                            Text(
                                              patient.lastVisit != null
                                                  ? 'Gần nhất: ${patient.lastVisit!.day}/${patient.lastVisit!.month}/${patient.lastVisit!.year}'
                                                  : 'Chưa có lịch sử',
                                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text('${patient.visitCount}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppEmptyState(
          icon: Icons.error_outline,
          title: 'Không tải được danh sách',
          subtitle: '$e',
          actionText: 'Thử lại',
          onAction: () => ref.invalidate(doctorPatientsProvider),
        ),
      ),
    );
  }

  void _showPatientDetail(BuildContext context, _PatientSummary patient) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5, expand: false,
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
                child: Center(child: Text(patient.name.isNotEmpty ? patient.name[0] : '?', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.primary))),
              )),
              AppSpacing.gapMd,
              Center(child: Text(patient.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
              Center(child: Text('${patient.visitCount} lần khám', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
              AppSpacing.gapXxl,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionBtn(icon: Icons.chat_rounded, label: 'Chat', color: AppColors.primary, onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatInboxScreen()));
                  }),
                  _ActionBtn(icon: Icons.videocam_rounded, label: 'Video', color: AppColors.success, onTap: () {}),
                  _ActionBtn(icon: Icons.folder_rounded, label: 'Hồ sơ', color: AppColors.secondary, onTap: () {}),
                ],
              ),
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
