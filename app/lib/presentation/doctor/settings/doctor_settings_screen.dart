import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/doctor_model.dart';
import 'package:doctor_booking_app/data/repositories/doctor_repository.dart';

/// Provider for doctor settings data
final doctorSettingsProvider = FutureProvider<DoctorModel>((ref) {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  return ref.watch(doctorRepositoryProvider).getDoctorById(userId);
});

class DoctorSettingsScreen extends ConsumerStatefulWidget {
  const DoctorSettingsScreen({super.key});

  @override
  ConsumerState<DoctorSettingsScreen> createState() => _DoctorSettingsScreenState();
}

class _DoctorSettingsScreenState extends ConsumerState<DoctorSettingsScreen> {
  bool _autoConfirm = false;
  bool _allowVideo = true;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _chatNotifications = true;
  bool _isLoaded = false;

  void _loadFromDoctor(DoctorModel doctor) {
    if (_isLoaded) return;
    _isLoaded = true;
    _allowVideo = doctor.isAvailable;
  }

  Future<void> _updateDoctorField(String field, dynamic value) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client.from('doctors').update({field: value}).eq('id', userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(doctorSettingsProvider);
    final feeFormatter = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: doctorAsync.when(
        data: (doctor) {
          _loadFromDoctor(doctor);

          final feeStr = '${feeFormatter.format(doctor.consultationFee.toInt())}đ';

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            children: [
              _Section(title: 'TÀI KHOẢN', children: [
                _SettingsTile(icon: Icons.person_outline, color: AppColors.primary, title: 'Thông tin cá nhân', onTap: () {}),
                _SettingsTile(icon: Icons.lock_outline, color: AppColors.accent, title: 'Đổi mật khẩu', onTap: () {}),
                _SettingsTile(icon: Icons.shield_outlined, color: AppColors.success, title: 'Bảo mật', onTap: () {}),
              ]),
              _Section(title: 'LỊCH HẸN', children: [
                _ToggleTile(
                  icon: Icons.auto_awesome_rounded,
                  color: AppColors.secondary,
                  title: 'Tự động xác nhận',
                  subtitle: 'Tự động chấp nhận lịch hẹn mới',
                  value: _autoConfirm,
                  onChanged: (v) => setState(() => _autoConfirm = v),
                ),
                _ToggleTile(
                  icon: Icons.videocam_rounded,
                  color: AppColors.success,
                  title: 'Cho phép Video Call',
                  subtitle: 'Bệnh nhân có thể đặt khám online',
                  value: _allowVideo,
                  onChanged: (v) {
                    setState(() => _allowVideo = v);
                    _updateDoctorField('is_available', v);
                  },
                ),
                _SettingsTile(
                  icon: Icons.schedule_rounded,
                  color: AppColors.primary,
                  title: 'Thời lượng khám',
                  trailing: '30 phút',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.monetization_on_outlined,
                  color: AppColors.accent,
                  title: 'Phí khám',
                  trailing: feeStr,
                  onTap: () => _showEditFeeDialog(doctor),
                ),
              ]),
              _Section(title: 'THÔNG BÁO', children: [
                _ToggleTile(
                  icon: Icons.notifications_outlined,
                  color: AppColors.accent,
                  title: 'Push notifications',
                  value: _pushNotifications,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                ),
                _ToggleTile(
                  icon: Icons.email_outlined,
                  color: AppColors.primary,
                  title: 'Email thông báo',
                  value: _emailNotifications,
                  onChanged: (v) => setState(() => _emailNotifications = v),
                ),
                _ToggleTile(
                  icon: Icons.chat_outlined,
                  color: AppColors.success,
                  title: 'Thông báo tin nhắn',
                  value: _chatNotifications,
                  onChanged: (v) => setState(() => _chatNotifications = v),
                ),
              ]),
              _Section(title: 'ỨNG DỤNG', children: [
                _SettingsTile(icon: Icons.language_rounded, color: AppColors.secondary, title: 'Ngôn ngữ', trailing: 'Tiếng Việt', onTap: () {}),
                _SettingsTile(icon: Icons.dark_mode_rounded, color: AppColors.textSecondary, title: 'Giao diện', trailing: 'Theo hệ thống', onTap: () {}),
                _SettingsTile(icon: Icons.info_outline_rounded, color: AppColors.textTertiary, title: 'Phiên bản', trailing: '1.0.0', onTap: () {}),
              ]),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: const Text('Doctor Booking App v1.0.0', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              AppSpacing.gapMd,
              Text('Lỗi: $e', textAlign: TextAlign.center),
              AppSpacing.gapMd,
              FilledButton(
                onPressed: () => ref.invalidate(doctorSettingsProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditFeeDialog(DoctorModel doctor) async {
    final controller = TextEditingController(text: doctor.consultationFee.toInt().toString());
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật phí khám'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Phí khám (VNĐ)',
            suffixText: 'đ',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final fee = double.tryParse(result);
      if (fee != null) {
        await _updateDoctorField('consultation_fee', fee);
        ref.invalidate(doctorSettingsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật phí khám'), backgroundColor: AppColors.success),
          );
        }
      }
    }
    controller.dispose();
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
        child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.8)),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: AppDecorations.cardFlat,
        child: Column(children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) AppDecorations.thinDivider,
          ],
        ]),
      ),
    ]);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.color, required this.title, this.trailing, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(children: [
            Container(width: 32, height: 32, decoration: AppDecorations.iconContainer(color), child: Icon(icon, size: 16, color: color)),
            AppSpacing.gapHMd,
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            if (trailing != null) Text(trailing!, style: const TextStyle(fontSize: 13, color: AppColors.textTertiary)),
            AppSpacing.gapHSm,
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
          ]),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.icon, required this.color, required this.title, this.subtitle, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: Row(children: [
        Container(width: 32, height: 32, decoration: AppDecorations.iconContainer(color), child: Icon(icon, size: 16, color: color)),
        AppSpacing.gapHMd,
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ])),
        Switch(value: value, onChanged: onChanged, activeTrackColor: AppColors.primary),
      ]),
    );
  }
}
