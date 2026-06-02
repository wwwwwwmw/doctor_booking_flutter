import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/core/di/di_providers.dart';
import 'package:doctor_booking_app/core/error/failures.dart';
import 'package:doctor_booking_app/data/models/doctor_model.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';
import 'package:doctor_booking_app/presentation/patient/doctor_detail/doctor_detail_screen.dart';

/// Model for a favorite entry with joined doctor data
class FavoriteItem {
  final String favoriteId;
  final DoctorModel doctor;

  FavoriteItem({required this.favoriteId, required this.doctor});
}

/// Provider: fetch favorites for the current logged-in user only
final userFavoritesProvider = FutureProvider<List<FavoriteItem>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = Supabase.instance.client.auth.currentUser!.id;

  try {
    final data = await client
        .from('favorites')
        .select('id, doctor_id, doctors(*, users(full_name, avatar_url), specialities(name, name_vi))')
        .eq('patient_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) {
      final doctorJson = e['doctors'] as Map<String, dynamic>;
      return FavoriteItem(
        favoriteId: e['id'] as String,
        doctor: DoctorModel.fromJson(doctorJson),
      );
    }).toList();
  } on PostgrestException catch (e) {
    throw ServerFailure(e.message);
  }
});

class FavoriteDoctorsScreen extends ConsumerWidget {
  const FavoriteDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(userFavoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bác sĩ yêu thích')),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return const AppEmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Chưa có bác sĩ yêu thích',
              subtitle: 'Thêm bác sĩ yêu thích từ trang tìm kiếm',
              actionText: 'Tìm bác sĩ',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userFavoritesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final fav = favorites[index];
                final doctor = fav.doctor;
                final displayName = doctor.fullName ?? 'Bác sĩ';

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: AppDecorations.card,
                  child: InkWell(
                    borderRadius: AppSpacing.borderRadiusMd,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctorId: doctor.id))),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              borderRadius: AppSpacing.borderRadiusMd,
                              color: AppColors.primarySurface,
                              image: doctor.avatarUrl != null
                                  ? DecorationImage(image: NetworkImage(doctor.avatarUrl!), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: doctor.avatarUrl == null
                                ? Center(
                                    child: Text(
                                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primary),
                                    ),
                                  )
                                : null,
                          ),
                          AppSpacing.gapHMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                AppSpacing.gapXs,
                                Text(
                                  '${doctor.specialityNameVi ?? doctor.specialityName ?? ''} • ${doctor.hospital ?? ''}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                AppSpacing.gapXs,
                                Row(children: [
                                  Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade700),
                                  AppSpacing.gapHXs,
                                  Text(doctor.displayRating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                  AppSpacing.gapHMd,
                                  const Icon(Icons.work_outline_rounded, size: 14, color: AppColors.textTertiary),
                                  AppSpacing.gapHXs,
                                  Text('${doctor.experienceYears} năm', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ]),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite_rounded, color: AppColors.error),
                            onPressed: () async {
                              try {
                                await ref.read(supabaseClientProvider)
                                    .from('favorites')
                                    .delete()
                                    .eq('id', fav.favoriteId);
                                ref.invalidate(userFavoritesProvider);
                              } catch (_) {}
                            },
                          ),
                        ],
                      ),
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
          title: 'Không tải được danh sách yêu thích',
          subtitle: '$e',
          actionText: 'Thử lại',
          onAction: () => ref.invalidate(userFavoritesProvider),
        ),
      ),
    );
  }
}
