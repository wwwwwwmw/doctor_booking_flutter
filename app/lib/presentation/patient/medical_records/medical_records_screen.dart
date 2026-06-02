import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/core/di/di_providers.dart';
import 'package:doctor_booking_app/core/error/failures.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

/// Model for medical record
class MedicalRecordItem {
  final String id;
  final String? diagnosis;
  final String? prescription;
  final String? notes;
  final String? doctorName;
  final DateTime createdAt;

  MedicalRecordItem({
    required this.id,
    this.diagnosis,
    this.prescription,
    this.notes,
    this.doctorName,
    required this.createdAt,
  });

  factory MedicalRecordItem.fromJson(Map<String, dynamic> json) {
    // Join with doctors → users to get doctor name
    final doctor = json['doctors'] as Map<String, dynamic>?;
    final doctorUser = doctor?['users'] as Map<String, dynamic>?;

    return MedicalRecordItem(
      id: json['id'] as String,
      diagnosis: json['diagnosis'] as String?,
      prescription: json['prescription'] as String?,
      notes: json['notes'] as String?,
      doctorName: doctorUser?['full_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Provider: fetch medical records for the current logged-in user only
final userMedicalRecordsProvider = FutureProvider<List<MedicalRecordItem>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = Supabase.instance.client.auth.currentUser!.id;

  try {
    final data = await client
        .from('medical_records')
        .select('*, doctors(users(full_name))')
        .eq('patient_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => MedicalRecordItem.fromJson(e)).toList();
  } on PostgrestException catch (e) {
    throw ServerFailure(e.message);
  }
});

class MedicalRecordsScreen extends ConsumerWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(userMedicalRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ y tế'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () {}),
        ],
      ),
      body: recordsAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return const AppEmptyState(
              icon: Icons.folder_open_rounded,
              title: 'Chưa có hồ sơ y tế',
              subtitle: 'Hồ sơ y tế sẽ xuất hiện sau khi bạn khám bệnh',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userMedicalRecordsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final dateStr = '${record.createdAt.day.toString().padLeft(2, '0')}/${record.createdAt.month.toString().padLeft(2, '0')}/${record.createdAt.year}';

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: AppDecorations.card,
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                      childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                      leading: Container(
                        width: 40, height: 40,
                        decoration: AppDecorations.iconContainer(AppColors.primary),
                        child: const Icon(Icons.description_rounded, color: AppColors.primary, size: 20),
                      ),
                      title: Text(
                        record.diagnosis ?? 'Chưa có chẩn đoán',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${record.doctorName ?? 'Bác sĩ'} • $dateStr',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      children: [
                        AppDecorations.thinDivider,
                        AppSpacing.gapMd,
                        _InfoRow(label: 'Chẩn đoán', value: record.diagnosis ?? 'Không có'),
                        AppSpacing.gapSm,
                        _InfoRow(label: 'Đơn thuốc', value: record.prescription ?? 'Không có'),
                        AppSpacing.gapSm,
                        _InfoRow(label: 'Ngày khám', value: dateStr),
                        _InfoRow(label: 'Bác sĩ', value: record.doctorName ?? 'Không rõ'),
                        if (record.notes != null && record.notes!.isNotEmpty) ...[
                          AppSpacing.gapSm,
                          _InfoRow(label: 'Ghi chú', value: record.notes!),
                        ],
                        AppSpacing.gapLg,
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.download_rounded, size: 16),
                                label: const Text('Tải PDF'),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                              ),
                            ),
                            AppSpacing.gapHSm,
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.share_rounded, size: 16),
                                label: const Text('Chia sẻ'),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppEmptyState(
          icon: Icons.error_outline,
          title: 'Không tải được hồ sơ y tế',
          subtitle: '$e',
          actionText: 'Thử lại',
          onAction: () => ref.invalidate(userMedicalRecordsProvider),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
    ]);
  }
}
