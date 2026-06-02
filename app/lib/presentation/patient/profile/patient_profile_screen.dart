import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/user_model.dart';
import 'package:doctor_booking_app/data/repositories/auth_repository.dart';
import 'package:doctor_booking_app/presentation/common/auth/login_screen.dart';
import 'package:doctor_booking_app/presentation/common/profile/profile_edit_screen.dart';
import 'package:doctor_booking_app/presentation/common/settings/settings_screen.dart';
import 'package:doctor_booking_app/presentation/patient/medical_records/medical_records_screen.dart';
import 'package:doctor_booking_app/presentation/patient/favorites/favorite_doctors_screen.dart';
import 'package:doctor_booking_app/presentation/patient/payment/payment_history_screen.dart';

final userProfileProvider = FutureProvider<UserModel>((ref) {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  return ref.watch(authRepositoryProvider).getUserProfile(userId);
});

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: profileAsync.when(
        data: (user) => CustomScrollView(
          slivers: [
            // Gradient header with avatar
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + AppSpacing.xxl,
                  bottom: AppSpacing.xxxl,
                ),
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppSpacing.radiusXxl),
                    bottomRight: Radius.circular(AppSpacing.radiusXxl),
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: AppSpacing.avatarXl,
                      height: AppSpacing.avatarXl,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                        image: user.avatarUrl != null
                            ? DecorationImage(image: NetworkImage(user.avatarUrl!), fit: BoxFit.cover)
                            : null,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: user.avatarUrl == null
                          ? Center(child: Text(user.fullName[0].toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white)))
                          : null,
                    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                    AppSpacing.gapMd,
                    Text(user.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)).animate().fadeIn(delay: 100.ms),
                    AppSpacing.gapXs,
                    Text(user.email, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.screenPaddingAll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal info
                    const Text('Thông tin cá nhân', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
                    AppSpacing.gapMd,
                    Container(
                      decoration: AppDecorations.cardFlat,
                      child: Column(
                        children: [
                          _InfoRow(icon: Icons.phone_outlined, label: 'Điện thoại', value: user.phone ?? 'Chưa cập nhật'),
                          AppDecorations.thinDivider,
                          _InfoRow(
                            icon: Icons.cake_outlined,
                            label: 'Ngày sinh',
                            value: user.dateOfBirth != null
                                ? '${user.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}'
                                : 'Chưa cập nhật',
                          ),
                          AppDecorations.thinDivider,
                          _InfoRow(
                            icon: Icons.wc_outlined,
                            label: 'Giới tính',
                            value: user.gender == 'male' ? 'Nam' : user.gender == 'female' ? 'Nữ' : 'Chưa cập nhật',
                          ),
                          AppDecorations.thinDivider,
                          _InfoRow(icon: Icons.bloodtype_outlined, label: 'Nhóm máu', value: user.bloodType ?? 'Chưa cập nhật'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    AppSpacing.gapXxl,

                    // Actions
                    const Text('Quản lý', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
                    AppSpacing.gapMd,
                    Container(
                      decoration: AppDecorations.cardFlat,
                      child: Column(
                        children: [
                          _ActionRow(
                            icon: Icons.edit_outlined,
                            color: AppColors.primary,
                            title: 'Chỉnh sửa hồ sơ',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
                          ),
                          AppDecorations.thinDivider,
                          _ActionRow(
                            icon: Icons.folder_shared_outlined,
                            color: AppColors.secondary,
                            title: 'Hồ sơ y tế',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalRecordsScreen())),
                          ),
                          AppDecorations.thinDivider,
                          _ActionRow(
                            icon: Icons.favorite_outlined,
                            color: AppColors.error,
                            title: 'Bác sĩ yêu thích',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteDoctorsScreen())),
                          ),
                          AppDecorations.thinDivider,
                          _ActionRow(
                            icon: Icons.receipt_long_outlined,
                            color: AppColors.accent,
                            title: 'Lịch sử thanh toán',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen())),
                          ),
                          AppDecorations.thinDivider,
                          _ActionRow(
                            icon: Icons.settings_outlined,
                            color: AppColors.textSecondary,
                            title: 'Cài đặt',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    AppSpacing.gapXxl,

                    // Logout
                    Container(
                      decoration: AppDecorations.cardFlat,
                      child: _ActionRow(
                        icon: Icons.logout_rounded,
                        color: AppColors.error,
                        title: 'Đăng xuất',
                        onTap: () async {
                          await ref.read(authRepositoryProvider).signOut();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                    AppSpacing.gapXxxl,
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: AppDecorations.iconContainer(AppColors.primary),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          AppSpacing.gapHMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  const _ActionRow({required this.icon, required this.color, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: AppDecorations.iconContainer(color),
                child: Icon(icon, size: 18, color: color),
              ),
              AppSpacing.gapHMd,
              Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
