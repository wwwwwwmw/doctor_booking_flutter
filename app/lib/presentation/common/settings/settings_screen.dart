import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDarkMode = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _reminderBefore1Hour = true;
  bool _reminderBefore1Day = true;
  String _language = 'vi';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: AppSpacing.screenPaddingAll,
        children: [
          // Appearance
          _buildSectionTitle('Giao diện'),
          AppSpacing.gapSm,
          Container(
            decoration: AppDecorations.cardFlat,
            child: Column(
              children: [
                _buildSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Chế độ tối',
                  subtitle: 'Giảm mỏi mắt khi dùng ban đêm',
                  value: _isDarkMode,
                  onChanged: (v) => setState(() => _isDarkMode = v),
                ),
                AppDecorations.thinDivider,
                _buildLanguageTile(theme),
              ],
            ),
          ),
          AppSpacing.gapXxl,

          // Notifications
          _buildSectionTitle('Thông báo'),
          AppSpacing.gapSm,
          Container(
            decoration: AppDecorations.cardFlat,
            child: Column(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Thông báo đẩy',
                  subtitle: 'Nhận thông báo trên điện thoại',
                  value: _pushNotifications,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                ),
                AppDecorations.thinDivider,
                _buildSwitchTile(
                  icon: Icons.email_outlined,
                  title: 'Thông báo email',
                  subtitle: 'Nhận thông báo qua email',
                  value: _emailNotifications,
                  onChanged: (v) => setState(() => _emailNotifications = v),
                ),
                AppDecorations.thinDivider,
                _buildSwitchTile(
                  icon: Icons.alarm,
                  title: 'Nhắc nhở trước 1 giờ',
                  subtitle: 'Nhắc trước lịch hẹn 1 giờ',
                  value: _reminderBefore1Hour,
                  onChanged: (v) => setState(() => _reminderBefore1Hour = v),
                ),
                AppDecorations.thinDivider,
                _buildSwitchTile(
                  icon: Icons.calendar_today,
                  title: 'Nhắc nhở trước 1 ngày',
                  subtitle: 'Nhắc trước lịch hẹn 1 ngày',
                  value: _reminderBefore1Day,
                  onChanged: (v) => setState(() => _reminderBefore1Day = v),
                ),
              ],
            ),
          ),
          AppSpacing.gapXxl,

          // Account
          _buildSectionTitle('Tài khoản'),
          AppSpacing.gapSm,
          Container(
            decoration: AppDecorations.cardFlat,
            child: Column(
              children: [
                _buildNavTile(
                  icon: Icons.lock_outline,
                  title: 'Đổi mật khẩu',
                  onTap: () {},
                ),
                AppDecorations.thinDivider,
                _buildNavTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Chính sách quyền riêng tư',
                  onTap: () {},
                ),
                AppDecorations.thinDivider,
                _buildNavTile(
                  icon: Icons.description_outlined,
                  title: 'Điều khoản sử dụng',
                  onTap: () {},
                ),
              ],
            ),
          ),
          AppSpacing.gapXxl,

          // About
          _buildSectionTitle('Thông tin'),
          AppSpacing.gapSm,
          Container(
            decoration: AppDecorations.cardFlat,
            child: Column(
              children: [
                _buildNavTile(
                  icon: Icons.info_outline,
                  title: 'Về ứng dụng',
                  trailing: const Text('v1.0.0', style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                  onTap: () {},
                ),
                AppDecorations.thinDivider,
                _buildNavTile(
                  icon: Icons.star_outline,
                  title: 'Đánh giá ứng dụng',
                  onTap: () {},
                ),
                AppDecorations.thinDivider,
                _buildNavTile(
                  icon: Icons.help_outline,
                  title: 'Trung tâm hỗ trợ',
                  onTap: () {},
                ),
              ],
            ),
          ),
          AppSpacing.gapXxl,

          // Danger zone
          Container(
            decoration: AppDecorations.cardFlat,
            child: _buildNavTile(
              icon: Icons.delete_outline,
              title: 'Xóa tài khoản',
              titleColor: AppColors.error,
              onTap: () => _showDeleteAccountDialog(),
            ),
          ),
          AppSpacing.gapXxxl,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: AppDecorations.iconContainer(AppColors.primary),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          AppSpacing.gapHMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: AppDecorations.iconContainer(AppColors.secondary),
            child: const Icon(Icons.language, size: 18, color: AppColors.secondary),
          ),
          AppSpacing.gapHMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ngôn ngữ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const Text('Chọn ngôn ngữ hiển thị', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),
          DropdownButton<String>(
            value: _language,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (v) => setState(() => _language = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, size: 20, color: titleColor ?? AppColors.textSecondary),
              AppSpacing.gapHMd,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: titleColor),
                ),
              ),
              trailing ?? const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tài khoản'),
        content: const Text('Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
