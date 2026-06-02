import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/doctor_model.dart';
import 'package:doctor_booking_app/data/repositories/doctor_repository.dart';
import 'package:doctor_booking_app/presentation/common/auth/login_screen.dart';
import 'package:doctor_booking_app/presentation/common/notifications/notifications_screen.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';
import 'package:doctor_booking_app/presentation/patient/search/search_doctors_screen.dart';
import 'package:doctor_booking_app/presentation/patient/calendar/patient_calendar_screen.dart';
import 'package:doctor_booking_app/presentation/patient/profile/patient_profile_screen.dart';
import 'package:doctor_booking_app/presentation/patient/doctor_detail/doctor_detail_screen.dart';
import 'package:doctor_booking_app/presentation/patient/medical_records/medical_records_screen.dart';
import 'package:doctor_booking_app/presentation/chat/chat_inbox_screen.dart';

/// Top doctors provider
final topDoctorsProvider = FutureProvider<List<DoctorModel>>((ref) {
  return ref.watch(doctorRepositoryProvider).getTopDoctors(limit: 5);
});

/// Specialities provider
final homeSpecialitiesProvider = FutureProvider<List<SpecialityModel>>((ref) {
  return ref.watch(doctorRepositoryProvider).getSpecialities();
});

class PatientHomeScreen extends ConsumerStatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  ConsumerState<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends ConsumerState<PatientHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _HomeBody(),
      const PatientCalendarScreen(),
      const ChatInboxScreen(),
      const PatientProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Trang chủ'),
            NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Lịch hẹn'),
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Hồ sơ'),
          ],
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final specialitiesAsync = ref.watch(homeSpecialitiesProvider);
    final topDoctorsAsync = ref.watch(topDoctorsProvider);
    final userName = user?.userMetadata?['full_name'] ?? 'Bệnh nhân';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homeSpecialitiesProvider);
          ref.invalidate(topDoctorsProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Gradient header
            SliverToBoxAdapter(
              child: AppGradientHeader(
                greeting: 'Xin chào 👋',
                title: userName,
                subtitle: 'Bạn muốn khám gì hôm nay?',
                avatarInitial: userName[0].toUpperCase(),
                actions: [
                  _headerIconButton(Icons.notifications_outlined, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                  }),
                  AppSpacing.gapHSm,
                  _headerIconButton(Icons.logout_rounded, () async {
                    await Supabase.instance.client.auth.signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar (overlapping header)
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: AppSearchBar(
                        hint: 'Tìm kiếm bác sĩ, chuyên khoa...',
                        readOnly: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchDoctorsScreen())),
                      ),
                    ),
                    AppSpacing.gapSm,

                    // Quick actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _QuickAction(
                          icon: Icons.calendar_month_rounded,
                          label: 'Đặt lịch',
                          color: AppColors.primary,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchDoctorsScreen())),
                        ),
                        _QuickAction(
                          icon: Icons.videocam_rounded,
                          label: 'Video Call',
                          color: AppColors.success,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchDoctorsScreen())),
                        ),
                        _QuickAction(
                          icon: Icons.chat_bubble_rounded,
                          label: 'Chat',
                          color: AppColors.accent,
                          onTap: () {
                            // Navigate to chat inbox directly
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatInboxScreen()));
                          },
                        ),
                        _QuickAction(
                          icon: Icons.folder_shared_rounded,
                          label: 'Hồ sơ',
                          color: AppColors.secondary,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalRecordsScreen())),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    AppSpacing.gapXxl,

                    // Specialities
                    AppSectionHeader(
                      title: 'Chuyên khoa',
                      actionText: 'Xem tất cả',
                      onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchDoctorsScreen())),
                    ),
                    AppSpacing.gapMd,
                    specialitiesAsync.when(
                      data: (specs) => SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: specs.length,
                          separatorBuilder: (_, __) => AppSpacing.gapHMd,
                          itemBuilder: (context, index) {
                            final spec = specs[index];
                            final color = AppColors.categoryColor(index);
                            return _SpecialityChip(
                              name: spec.nameVi,
                              color: color,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchDoctorsScreen())),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      loading: () => SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          separatorBuilder: (_, __) => AppSpacing.gapHMd,
                          itemBuilder: (_, __) => const AppShimmerLoading(width: 70, height: 90, borderRadius: 16),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    AppSpacing.gapXxl,

                    // Top doctors
                    AppSectionHeader(
                      title: 'Bác sĩ nổi bật',
                      actionText: 'Xem tất cả',
                      onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchDoctorsScreen())),
                    ),
                    AppSpacing.gapMd,
                    topDoctorsAsync.when(
                      data: (doctors) {
                        if (doctors.isEmpty) {
                          return const AppEmptyState(
                            icon: Icons.person_search,
                            title: 'Chưa có bác sĩ nào',
                            subtitle: 'Danh sách bác sĩ sẽ hiển thị ở đây',
                          );
                        }
                        return Column(
                          children: doctors.asMap().entries.map((entry) {
                            final doctor = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: AppDoctorCard(
                                name: doctor.fullName,
                                speciality: doctor.specialityNameVi,
                                hospital: doctor.hospital,
                                avatarUrl: doctor.avatarUrl,
                                rating: doctor.displayRating,
                                ratingCount: doctor.ratingCount,
                                experience: doctor.experienceYears,
                                fee: doctor.displayFee,
                                isVerified: doctor.isVerified,
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctorId: doctor.id))),
                              ).animate().fadeIn(delay: Duration(milliseconds: 400 + entry.key * 100)),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => Column(
                        children: List.generate(3, (i) => const Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppShimmerLoading(height: 100),
                        )),
                      ),
                      error: (e, _) => AppEmptyState(
                        icon: Icons.error_outline,
                        title: 'Không tải được dữ liệu',
                        subtitle: '$e',
                        actionText: 'Thử lại',
                        onAction: () => ref.invalidate(topDoctorsProvider),
                      ),
                    ),
                    AppSpacing.gapXxxl,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIconButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusLg,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: AppDecorations.iconContainer(color, radius: 16),
            child: Icon(icon, color: color, size: 26),
          ),
          AppSpacing.gapSm,
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _SpecialityChip extends StatelessWidget {
  final String name;
  final Color color;
  final VoidCallback onTap;

  const _SpecialityChip({required this.name, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: AppDecorations.iconContainer(color, radius: 16),
            child: Icon(Icons.medical_services_rounded, color: color, size: 26),
          ),
          AppSpacing.gapSm,
          SizedBox(
            width: 70,
            child: Text(
              name,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
