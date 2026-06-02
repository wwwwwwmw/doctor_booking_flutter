import 'package:flutter/material.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Nguyễn Văn A');
  final _phoneCtrl = TextEditingController(text: '0901234567');
  String _gender = 'male';
  String _bloodType = 'O+';
  DateTime _dob = DateTime(1994, 5, 15);
  bool _isSaving = false;

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Lưu'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPaddingAll,
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: AppSpacing.avatarXl,
                  height: AppSpacing.avatarXl,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primarySurface,
                  ),
                  child: Center(
                    child: Text(
                      _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            AppSpacing.gapXxl,

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person_outlined)),
              validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập họ tên' : null,
            ),
            AppSpacing.gapLg,

            // Phone
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Số điện thoại', prefixIcon: Icon(Icons.phone_outlined)),
              keyboardType: TextInputType.phone,
            ),
            AppSpacing.gapXxl,

            // Date of birth
            Container(
              decoration: AppDecorations.cardFlat,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context, initialDate: _dob,
                      firstDate: DateTime(1920), lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _dob = picked);
                  },
                  borderRadius: AppSpacing.borderRadiusMd,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: AppDecorations.iconContainer(AppColors.accent),
                          child: const Icon(Icons.cake_outlined, size: 18, color: AppColors.accent),
                        ),
                        AppSpacing.gapHMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ngày sinh', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                              Text('${_dob.day}/${_dob.month}/${_dob.year}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit_outlined, size: 18, color: AppColors.textTertiary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AppSpacing.gapLg,

            // Gender
            Container(
              decoration: AppDecorations.cardFlat,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: AppDecorations.iconContainer(AppColors.secondary),
                    child: const Icon(Icons.wc_outlined, size: 18, color: AppColors.secondary),
                  ),
                  AppSpacing.gapHMd,
                  const Expanded(child: Text('Giới tính', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'male', label: Text('Nam')),
                      ButtonSegment(value: 'female', label: Text('Nữ')),
                      ButtonSegment(value: 'other', label: Text('Khác')),
                    ],
                    selected: {_gender},
                    onSelectionChanged: (s) => setState(() => _gender = s.first),
                    style: SegmentedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,

            // Blood type
            Container(
              decoration: AppDecorations.cardFlat,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: AppDecorations.iconContainer(AppColors.error),
                    child: const Icon(Icons.bloodtype_outlined, size: 18, color: AppColors.error),
                  ),
                  AppSpacing.gapHMd,
                  const Expanded(child: Text('Nhóm máu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                  DropdownButton<String>(
                    value: _bloodType,
                    underline: const SizedBox(),
                    items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _bloodType = v!),
                  ),
                ],
              ),
            ),
            AppSpacing.gapXxxl,

            // Delete account
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Xóa tài khoản?'),
                  content: const Text('Hành động này không thể hoàn tác. Tất cả dữ liệu sẽ bị xóa vĩnh viễn.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
              label: const Text('Xóa tài khoản', style: TextStyle(color: AppColors.error)),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã lưu hồ sơ'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  }
}
