import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/data/models/doctor_model.dart';
import 'package:doctor_booking_app/data/repositories/doctor_repository.dart';
import 'package:doctor_booking_app/presentation/patient/doctor_detail/doctor_detail_screen.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

// Providers
final specialitiesProvider = FutureProvider<List<SpecialityModel>>((ref) {
  return ref.watch(doctorRepositoryProvider).getSpecialities();
});

final doctorsProvider = FutureProvider.family<List<DoctorModel>, String?>((ref, specialityId) {
  return ref.watch(doctorRepositoryProvider).getDoctors(specialityId: specialityId);
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedSpecialityProvider = StateProvider<String?>((ref) => null);

class SearchDoctorsScreen extends ConsumerWidget {
  const SearchDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedSpeciality = ref.watch(selectedSpecialityProvider);
    final specialities = ref.watch(specialitiesProvider);
    final doctors = ref.watch(doctorsProvider(selectedSpeciality));

    return Scaffold(
      appBar: AppBar(title: const Text('Tìm bác sĩ')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppSearchBar(
              hint: 'Tìm theo tên, chuyên khoa, bệnh viện...',
              onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            ),
          ),

          // Speciality filter chips
          specialities.when(
            data: (specs) => SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: specs.length + 1,
                separatorBuilder: (_, __) => AppSpacing.gapHSm,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return FilterChip(
                      label: const Text('Tất cả'),
                      selected: selectedSpeciality == null,
                      onSelected: (_) => ref.read(selectedSpecialityProvider.notifier).state = null,
                    );
                  }
                  final spec = specs[index - 1];
                  return FilterChip(
                    label: Text(spec.nameVi),
                    selected: selectedSpeciality == spec.id,
                    onSelected: (_) => ref.read(selectedSpecialityProvider.notifier).state =
                        selectedSpeciality == spec.id ? null : spec.id,
                  );
                },
              ),
            ),
            loading: () => const SizedBox(height: 48),
            error: (_, __) => const SizedBox.shrink(),
          ),
          AppSpacing.gapSm,

          // Results
          Expanded(
            child: doctors.when(
              data: (list) {
                final filtered = searchQuery.isEmpty
                    ? list
                    : list.where((d) =>
                        (d.fullName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
                        (d.specialityNameVi?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
                        (d.hospital?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)).toList();

                if (filtered.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Không tìm thấy bác sĩ',
                    subtitle: 'Thử thay đổi từ khóa hoặc bộ lọc',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => AppSpacing.gapMd,
                  itemBuilder: (context, index) {
                    final doctor = filtered[index];
                    return AppDoctorCard(
                      name: doctor.fullName,
                      speciality: doctor.specialityNameVi ?? doctor.specialityName,
                      hospital: doctor.hospital,
                      avatarUrl: doctor.avatarUrl,
                      rating: doctor.displayRating,
                      ratingCount: doctor.ratingCount,
                      experience: doctor.experienceYears,
                      fee: doctor.displayFee,
                      isVerified: doctor.isVerified,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctorId: doctor.id))),
                    ).animate().fadeIn(delay: Duration(milliseconds: index * 80)).slideX(begin: 0.05);
                  },
                );
              },
              loading: () => Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: List.generate(4, (_) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: AppShimmerLoading(height: 100),
                  )),
                ),
              ),
              error: (e, _) => AppEmptyState(
                icon: Icons.error_outline,
                title: 'Không tải được dữ liệu',
                subtitle: '$e',
                actionText: 'Thử lại',
                onAction: () => ref.invalidate(doctorsProvider(selectedSpeciality)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
