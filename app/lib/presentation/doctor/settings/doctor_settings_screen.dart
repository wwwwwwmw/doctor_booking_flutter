import 'package:flutter/material.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';

class DoctorSettingsScreen extends StatelessWidget {
  const DoctorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          _Section(title: 'TÀI KHOẢN', children: [
            _SettingsTile(icon: Icons.person_outline, color: AppColors.primary, title: 'Thông tin cá nhân', onTap: () {}),
            _SettingsTile(icon: Icons.lock_outline, color: AppColors.accent, title: 'Đổi mật khẩu', onTap: () {}),
            _SettingsTile(icon: Icons.shield_outlined, color: AppColors.success, title: 'Bảo mật', onTap: () {}),
          ]),
          _Section(title: 'LỊCH HẸN', children: [
            _ToggleTile(icon: Icons.auto_awesome_rounded, color: AppColors.secondary, title: 'Tự động xác nhận', subtitle: 'Tự động chấp nhận lịch hẹn mới', value: false),
            _ToggleTile(icon: Icons.videocam_rounded, color: AppColors.success, title: 'Cho phép Video Call', subtitle: 'Bệnh nhân có thể đặt khám online', value: true),
            _SettingsTile(icon: Icons.schedule_rounded, color: AppColors.primary, title: 'Thời lượng khám', trailing: '30 phút', onTap: () {}),
            _SettingsTile(icon: Icons.monetization_on_outlined, color: AppColors.accent, title: 'Phí khám', trailing: '300.000đ', onTap: () {}),
          ]),
          _Section(title: 'THÔNG BÁO', children: [
            _ToggleTile(icon: Icons.notifications_outlined, color: AppColors.accent, title: 'Push notifications', value: true),
            _ToggleTile(icon: Icons.email_outlined, color: AppColors.primary, title: 'Email thông báo', value: true),
            _ToggleTile(icon: Icons.chat_outlined, color: AppColors.success, title: 'Thông báo tin nhắn', value: true),
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
      ),
    );
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
  const _ToggleTile({required this.icon, required this.color, required this.title, this.subtitle, required this.value});
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
        Switch(value: value, onChanged: (v) {}, activeTrackColor: AppColors.primary),
      ]),
    );
  }
}
