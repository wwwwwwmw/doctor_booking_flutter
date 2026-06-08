import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/doctor_model.dart';
import 'package:doctor_booking_app/data/repositories/admin_repository.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

class AdminDoctorApprovalScreen extends ConsumerStatefulWidget {
  const AdminDoctorApprovalScreen({super.key});

  @override
  ConsumerState<AdminDoctorApprovalScreen> createState() => _AdminDoctorApprovalScreenState();
}

class _AdminDoctorApprovalScreenState extends ConsumerState<AdminDoctorApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyệt bác sĩ'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(pendingDoctorsProvider);
              ref.invalidate(approvedDoctorsProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chờ duyệt'),
            Tab(text: 'Đã duyệt'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingTab(ref: ref),
          _ApprovedTab(ref: ref),
        ],
      ),
    );
  }
}

// ==================== TAB: PENDING ====================

class _PendingTab extends StatelessWidget {
  final WidgetRef ref;
  const _PendingTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingDoctorsProvider);

    return pendingAsync.when(
      data: (doctors) {
        if (doctors.isEmpty) {
          return const AppEmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: 'Không có bác sĩ chờ duyệt',
            subtitle: 'Tất cả hồ sơ đã được xử lý',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(pendingDoctorsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: doctors.length,
            itemBuilder: (context, index) => _PendingDoctorCard(
              doctor: doctors[index],
              onApprove: () => _approveDoctor(context, doctors[index]),
              onReject: () => _rejectDoctor(context, doctors[index]),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AppEmptyState(
        icon: Icons.error_outline,
        title: 'Không tải được danh sách',
        subtitle: '$e',
        actionText: 'Thử lại',
        onAction: () => ref.invalidate(pendingDoctorsProvider),
      ),
    );
  }

  Future<void> _approveDoctor(BuildContext context, DoctorModel doctor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Duyệt bác sĩ?'),
        content: Text('Xác nhận duyệt bác sĩ "${doctor.fullName ?? 'Chưa rõ'}"?\nBác sĩ sẽ có thể đăng nhập và nhận lịch hẹn.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Duyệt'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(adminRepositoryProvider).approveDoctor(doctor.id);
        ref.invalidate(pendingDoctorsProvider);
        ref.invalidate(approvedDoctorsProvider);
        ref.invalidate(adminStatsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Đã duyệt bác sĩ "${doctor.fullName}"'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  Future<void> _rejectDoctor(BuildContext context, DoctorModel doctor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối bác sĩ?'),
        content: Text('Bạn có chắc muốn từ chối bác sĩ "${doctor.fullName ?? 'Chưa rõ'}"?\nHồ sơ bác sĩ sẽ bị xóa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(adminRepositoryProvider).rejectDoctor(doctor.id);
        ref.invalidate(pendingDoctorsProvider);
        ref.invalidate(adminStatsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã từ chối bác sĩ "${doctor.fullName}"'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }
}

// ==================== TAB: APPROVED ====================

class _ApprovedTab extends StatelessWidget {
  final WidgetRef ref;
  const _ApprovedTab({required this.ref});

  @override
  Widget build(BuildContext context) {
    final approvedAsync = ref.watch(approvedDoctorsProvider);

    return approvedAsync.when(
      data: (doctors) {
        if (doctors.isEmpty) {
          return const AppEmptyState(
            icon: Icons.medical_services_outlined,
            title: 'Chưa có bác sĩ nào',
            subtitle: 'Bác sĩ đã duyệt sẽ xuất hiện ở đây',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(approvedDoctorsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: doctors.length,
            itemBuilder: (context, index) => _ApprovedDoctorCard(doctor: doctors[index]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AppEmptyState(
        icon: Icons.error_outline,
        title: 'Không tải được danh sách',
        subtitle: '$e',
        actionText: 'Thử lại',
        onAction: () => ref.invalidate(approvedDoctorsProvider),
      ),
    );
  }
}

// ==================== HELPER WIDGETS ====================

class _PendingDoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingDoctorCard({required this.doctor, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final displayName = doctor.fullName ?? 'Chưa rõ';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: AppDecorations.card,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    borderRadius: AppSpacing.borderRadiusMd,
                    color: AppColors.primarySurface,
                    image: doctor.avatarUrl != null
                        ? DecorationImage(image: NetworkImage(doctor.avatarUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: doctor.avatarUrl == null
                      ? Center(child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ))
                      : null,
                ),
                AppSpacing.gapHMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      AppSpacing.gapXs,
                      Text(
                        doctor.specialityNameVi ?? doctor.specialityName ?? 'Chưa chọn chuyên khoa',
                        style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
                      ),
                      if (doctor.hospital != null) ...[
                        AppSpacing.gapXs,
                        Row(children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textTertiary),
                          AppSpacing.gapHXs,
                          Expanded(child: Text(doctor.hospital!, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ]),
                      ],
                    ],
                  ),
                ),
                // Pending badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusPending.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: const Text('Chờ duyệt', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.statusPending)),
                ),
              ],
            ),
            AppSpacing.gapLg,
            // Info row
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primarySurface.withValues(alpha: 0.5),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.work_outline, size: 14, color: AppColors.textSecondary),
                  AppSpacing.gapHXs,
                  Text('${doctor.experienceYears} năm KN', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  AppSpacing.gapHLg,
                  const Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
                  AppSpacing.gapHXs,
                  Expanded(child: Text(doctor.email ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            AppSpacing.gapLg,
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Từ chối'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                AppSpacing.gapHMd,
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Duyệt'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovedDoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  const _ApprovedDoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final displayName = doctor.fullName ?? 'Bác sĩ';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: AppDecorations.card,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                borderRadius: AppSpacing.borderRadiusMd,
                color: AppColors.primarySurface,
                image: doctor.avatarUrl != null
                    ? DecorationImage(image: NetworkImage(doctor.avatarUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: doctor.avatarUrl == null
                  ? Center(child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ))
                  : null,
            ),
            AppSpacing.gapHMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                      const Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                  AppSpacing.gapXs,
                  Text(
                    '${doctor.specialityNameVi ?? ''} • ${doctor.hospital ?? ''}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.gapXs,
                  Row(children: [
                    Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade700),
                    AppSpacing.gapHXs,
                    Text(doctor.displayRating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    AppSpacing.gapHMd,
                    const Icon(Icons.work_outline, size: 14, color: AppColors.textTertiary),
                    AppSpacing.gapHXs,
                    Text('${doctor.experienceYears} năm', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
