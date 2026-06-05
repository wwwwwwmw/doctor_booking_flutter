import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/user_model.dart';
import 'package:doctor_booking_app/data/repositories/auth_repository.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _gender = '';
  String _bloodType = '';
  DateTime? _dob;
  bool _isSaving = false;
  bool _isLoaded = false;

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  void _loadFromUser(UserModel user) {
    if (_isLoaded) return;
    _nameCtrl.text = user.fullName;
    _phoneCtrl.text = user.phone ?? '';
    _gender = user.gender ?? '';
    _bloodType = user.bloodType ?? '';
    _dob = user.dateOfBirth;
    _isLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    return FutureBuilder<UserModel>(
      future: ref.read(authRepositoryProvider).getUserProfile(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !_isLoaded) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError && !_isLoaded) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
            body: Center(child: Text('Lỗi: ${snapshot.error}')),
          );
        }

        if (snapshot.hasData) {
          _loadFromUser(snapshot.data!);
        }

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
                      decoration: const BoxDecoration(
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
                          context: context, initialDate: _dob ?? DateTime(1990),
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
                                  Text(
                                    _dob != null ? '${_dob!.day}/${_dob!.month}/${_dob!.year}' : 'Chưa cập nhật',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
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
                        selected: _gender.isEmpty ? {} : {_gender},
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
                        value: _bloodType.isEmpty ? null : _bloodType,
                        hint: const Text('Chọn'),
                        underline: const SizedBox(),
                        items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => _bloodType = v ?? ''),
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
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final updates = <String, dynamic>{
        'full_name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        'gender': _gender.isEmpty ? null : _gender,
        'blood_type': _bloodType.isEmpty ? null : _bloodType,
        'date_of_birth': _dob?.toIso8601String().split('T')[0],
      };

      await ref.read(authRepositoryProvider).updateProfile(userId, updates);

      // Also update auth user metadata
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': _nameCtrl.text.trim()}),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã lưu hồ sơ'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
