import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/doctor_model.dart';
import 'package:doctor_booking_app/data/models/review_model.dart';
import 'package:doctor_booking_app/data/repositories/doctor_repository.dart';
import 'package:doctor_booking_app/data/repositories/review_repository.dart';
import 'package:doctor_booking_app/presentation/patient/booking/book_appointment_screen.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

final doctorDetailProvider = FutureProvider.family<DoctorModel, String>((ref, id) {
  return ref.watch(doctorRepositoryProvider).getDoctorById(id);
});

final doctorReviewsProvider = FutureProvider.family<List<ReviewModel>, String>((ref, id) {
  return ref.watch(reviewRepositoryProvider).getDoctorReviews(id);
});

class DoctorDetailScreen extends ConsumerWidget {
  final String doctorId;
  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(doctorDetailProvider(doctorId));
    final reviewsAsync = ref.watch(doctorReviewsProvider(doctorId));

    return Scaffold(
      body: doctorAsync.when(
        data: (doctor) => CustomScrollView(
          slivers: [
            // Hero header
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        // Avatar with ring
                        Container(
                          width: 108, height: 108,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            backgroundImage: doctor.avatarUrl != null
                                ? NetworkImage(doctor.avatarUrl!)
                                : null,
                            child: doctor.avatarUrl == null
                                ? Text(
                                    (doctor.fullName ?? 'D')[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.w600),
                                  )
                                : null,
                          ),
                        ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                        AppSpacing.gapMd,
                        Text(
                          doctor.fullName ?? 'Bác sĩ',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                        ).animate().fadeIn(delay: 100.ms),
                        AppSpacing.gapXs,
                        Text(
                          doctor.specialityNameVi ?? '',
                          style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.screenPaddingAll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats row
                    Container(
                      decoration: AppDecorations.cardElevated,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                            icon: Icons.star_rounded,
                            value: doctor.displayRating,
                            label: '${doctor.ratingCount} đánh giá',
                            color: AppColors.statusPending,
                          ),
                          Container(width: 1, height: 40, color: AppColors.border),
                          _StatItem(
                            icon: Icons.work_outline_rounded,
                            value: '${doctor.experienceYears}',
                            label: 'Năm kinh nghiệm',
                            color: AppColors.primary,
                          ),
                          Container(width: 1, height: 40, color: AppColors.border),
                          _StatItem(
                            icon: Icons.monetization_on_outlined,
                            value: doctor.displayFee,
                            label: 'Phí khám',
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    AppSpacing.gapXxl,

                    // Verified badge
                    if (doctor.isVerified) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        decoration: AppDecorations.chipDecoration(AppColors.primary),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded, size: 18, color: AppColors.primary),
                            AppSpacing.gapHSm,
                            const Text('Đã xác minh', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      AppSpacing.gapLg,
                    ],

                    // Hospital
                    if (doctor.hospital != null) ...[
                      _InfoTile(icon: Icons.local_hospital_rounded, label: 'Bệnh viện', value: doctor.hospital!),
                      AppSpacing.gapMd,
                    ],

                    // Bio section
                    if (doctor.bio != null) ...[
                      AppSpacing.gapMd,
                      const Text('Giới thiệu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      AppSpacing.gapSm,
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: AppDecorations.cardFlat,
                        child: Text(doctor.bio!, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary)),
                      ),
                      AppSpacing.gapXxl,
                    ],

                    // Reviews section
                    const AppSectionHeader(title: 'Đánh giá', actionText: 'Xem tất cả'),
                    AppSpacing.gapMd,
                    reviewsAsync.when(
                      data: (reviews) {
                        if (reviews.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            decoration: AppDecorations.cardFlat,
                            child: const Center(
                              child: Text('Chưa có đánh giá nào', style: TextStyle(color: AppColors.textTertiary)),
                            ),
                          );
                        }
                        return Column(
                          children: reviews.take(3).map((review) => _ReviewCard(review: review)).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Text('Không tải được đánh giá', style: TextStyle(color: AppColors.error)),
                    ),
                    const SizedBox(height: 100), // space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppEmptyState(icon: Icons.error_outline, title: 'Không tải được thông tin', subtitle: '$e'),
      ),

      // Book appointment button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: doctorAsync.whenOrNull(
        data: (doctor) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookAppointmentScreen(doctorId: doctorId, doctorName: doctor.fullName ?? 'Bác sĩ'),
                ),
              );
            },
            icon: const Icon(Icons.calendar_today_rounded),
            label: const Text('Đặt lịch khám', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40, height: 40,
          decoration: AppDecorations.iconContainer(color),
          child: Icon(icon, color: color, size: 20),
        ),
        AppSpacing.gapSm,
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        AppSpacing.gapXs,
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.cardFlat,
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: AppDecorations.iconContainer(AppColors.primary),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          AppSpacing.gapHMd,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primarySurface),
                child: Center(child: Text(review.displayName[0], style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary))),
              ),
              AppSpacing.gapHMd,
              Expanded(child: Text(review.displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
              ...List.generate(5, (i) => Icon(
                i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                size: 16,
                color: i < review.rating ? Colors.amber.shade700 : AppColors.textTertiary,
              )),
            ],
          ),
          if (review.comment != null) ...[
            AppSpacing.gapSm,
            Text(review.comment!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          ],
        ],
      ),
    );
  }
}
