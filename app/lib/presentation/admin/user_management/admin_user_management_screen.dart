import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/user_model.dart';
import 'package:doctor_booking_app/data/repositories/admin_repository.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends ConsumerState<AdminUserManagementScreen> {
  String? _roleFilter;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _invalidateUsers() {
    ref.invalidate(adminUsersProvider((role: _roleFilter, search: _searchQuery)));
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider((role: _roleFilter, search: _searchQuery)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _invalidateUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
            child: AppSearchBar(
              hint: 'Tìm theo tên, email, SĐT...',
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          AppSpacing.gapMd,

          // Role filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                _FilterChip(label: 'Tất cả', selected: _roleFilter == null,
                    onTap: () => setState(() => _roleFilter = null)),
                AppSpacing.gapHSm,
                _FilterChip(label: 'Bệnh nhân', selected: _roleFilter == 'patient',
                    onTap: () => setState(() => _roleFilter = 'patient')),
                AppSpacing.gapHSm,
                _FilterChip(label: 'Bác sĩ', selected: _roleFilter == 'doctor',
                    onTap: () => setState(() => _roleFilter = 'doctor')),
                AppSpacing.gapHSm,
                _FilterChip(label: 'Admin', selected: _roleFilter == 'admin',
                    onTap: () => setState(() => _roleFilter = 'admin')),
              ],
            ),
          ),
          AppSpacing.gapMd,

          // Users list
          Expanded(
            child: usersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.people_outline_rounded,
                    title: 'Không tìm thấy người dùng',
                    subtitle: 'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _invalidateUsers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: users.length,
                    itemBuilder: (context, index) => _UserCard(
                      user: users[index],
                      onEdit: () => _editUser(users[index]),
                      onToggleActive: () => _toggleUserActive(users[index]),
                      onDelete: () => _deleteUser(users[index]),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppEmptyState(
                icon: Icons.error_outline,
                title: 'Không tải được danh sách',
                subtitle: '$e',
                actionText: 'Thử lại',
                onAction: _invalidateUsers,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EDIT USER ====================

  Future<void> _editUser(UserModel user) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditUserSheet(user: user, adminRepo: ref.read(adminRepositoryProvider)),
    );

    if (result == true) {
      _invalidateUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật thông tin người dùng'), backgroundColor: AppColors.success),
        );
      }
    }
  }

  // ==================== TOGGLE ACTIVE ====================

  Future<void> _toggleUserActive(UserModel user) async {
    final newState = !user.isActive;
    final action = newState ? 'Kích hoạt' : 'Khóa';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action tài khoản?'),
        content: Text('Bạn có chắc muốn $action tài khoản "${user.fullName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(adminRepositoryProvider).toggleUserActive(user.id, newState);
        _invalidateUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã $action tài khoản "${user.fullName}"'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  // ==================== DELETE USER ====================

  Future<void> _deleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: Text('Bạn có chắc muốn xóa tài khoản "${user.fullName}"?\nHành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(adminRepositoryProvider).deleteUser(user.id);
        _invalidateUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xóa tài khoản "${user.fullName}"'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }
}

// ==================== EDIT USER BOTTOM SHEET ====================

class _EditUserSheet extends StatefulWidget {
  final UserModel user;
  final AdminRepository adminRepo;

  const _EditUserSheet({required this.user, required this.adminRepo});

  @override
  State<_EditUserSheet> createState() => _EditUserSheetState();
}

class _EditUserSheetState extends State<_EditUserSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late String _selectedRole;
  late String? _selectedGender;
  bool _isSaving = false;
  bool _showPassword = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController();
    _selectedRole = widget.user.role;
    _selectedGender = widget.user.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final newEmail = _emailController.text.trim();
      final newPassword = _passwordController.text.trim();
      final emailChanged = newEmail != widget.user.email;

      // 1. Cập nhật bảng users
      final updates = <String, dynamic>{
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'email': newEmail,
        'role': _selectedRole,
        'gender': _selectedGender,
      };
      await widget.adminRepo.updateUser(widget.user.id, updates);

      // 2. Cập nhật auth (email / password) qua Edge Function
      if (emailChanged || newPassword.isNotEmpty) {
        try {
          await widget.adminRepo.updateUserAuth(
            userId: widget.user.id,
            email: emailChanged ? newEmail : null,
            password: newPassword.isNotEmpty ? newPassword : null,
          );
        } catch (e) {
          // Edge function chưa được triển khai → thông báo
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                emailChanged && newPassword.isNotEmpty
                    ? 'Đã cập nhật thông tin. Lưu ý: Đổi email/mật khẩu đăng nhập cần triển khai Edge Function "admin-update-user".'
                    : emailChanged
                        ? 'Đã cập nhật thông tin. Lưu ý: Đổi email đăng nhập cần triển khai Edge Function.'
                        : 'Đã cập nhật thông tin. Lưu ý: Đổi mật khẩu cần triển khai Edge Function.',
              ),
              backgroundColor: AppColors.statusPending,
              duration: const Duration(seconds: 4),
            ),
          );
          Navigator.pop(context, true);
          return;
        }
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXxl)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.3),
                    borderRadius: AppSpacing.borderRadiusRound,
                  ),
                ),
              ),
              AppSpacing.gapSm,

              // Title
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: AppDecorations.iconContainer(AppColors.primary),
                    child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
                  ),
                  AppSpacing.gapHMd,
                  const Expanded(
                    child: Text(
                      'Chỉnh sửa thông tin',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              AppSpacing.gapXxl,

              // Full name
              const Text('Họ tên', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              AppSpacing.gapXs,
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Nhập họ tên',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
              ),
              AppSpacing.gapLg,

              // Email (editable)
              const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              AppSpacing.gapXs,
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Nhập email',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                  if (!v.contains('@') || !v.contains('.')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              AppSpacing.gapLg,

              // Password (new)
              const Text('Mật khẩu mới', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              AppSpacing.gapXs,
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: 'Để trống nếu không đổi',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              AppSpacing.gapLg,

              // Phone
              const Text('Số điện thoại', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              AppSpacing.gapXs,
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Nhập số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
              ),
              AppSpacing.gapLg,

              // Role + Gender row
              Row(
                children: [
                  // Role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vai trò', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        AppSpacing.gapXs,
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.badge_outlined, size: 20),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'patient', child: Text('Bệnh nhân')),
                            DropdownMenuItem(value: 'doctor', child: Text('Bác sĩ')),
                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          ],
                          onChanged: (v) => setState(() => _selectedRole = v!),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapHMd,
                  // Gender
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Giới tính', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        AppSpacing.gapXs,
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.wc_outlined, size: 20),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Chưa rõ')),
                            DropdownMenuItem(value: 'male', child: Text('Nam')),
                            DropdownMenuItem(value: 'female', child: Text('Nữ')),
                          ],
                          onChanged: (v) => setState(() => _selectedGender = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.gapXxl,

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(_isSaving ? 'Đang lưu...' : 'Lưu thay đổi'),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              AppSpacing.gapMd,
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== HELPER WIDGETS ====================

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: AppSpacing.borderRadiusRound,
          border: selected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _UserCard({required this.user, required this.onEdit, required this.onToggleActive, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final roleLabel = switch (user.role) {
      'doctor' => 'Bác sĩ',
      'admin' => 'Admin',
      _ => 'Bệnh nhân',
    };
    final roleColor = switch (user.role) {
      'doctor' => AppColors.success,
      'admin' => AppColors.secondary,
      _ => AppColors.primary,
    };
    final dateStr = '${user.createdAt.day.toString().padLeft(2, '0')}/${user.createdAt.month.toString().padLeft(2, '0')}/${user.createdAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: AppSpacing.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: roleColor.withValues(alpha: 0.12),
                  ),
                  child: Center(
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: roleColor),
                    ),
                  ),
                ),
                AppSpacing.gapHMd,
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.fullName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.1),
                              borderRadius: AppSpacing.borderRadiusSm,
                            ),
                            child: Text(roleLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: roleColor)),
                          ),
                        ],
                      ),
                      AppSpacing.gapXs,
                      Text(user.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      AppSpacing.gapXs,
                      Row(
                        children: [
                          Icon(
                            user.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            size: 12,
                            color: user.isActive ? AppColors.success : AppColors.error,
                          ),
                          AppSpacing.gapHXs,
                          Text(
                            user.isActive ? 'Hoạt động' : 'Đã khóa',
                            style: TextStyle(fontSize: 11, color: user.isActive ? AppColors.success : AppColors.error, fontWeight: FontWeight.w500),
                          ),
                          AppSpacing.gapHMd,
                          const Icon(Icons.calendar_today_outlined, size: 11, color: AppColors.textTertiary),
                          AppSpacing.gapHXs,
                          Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textTertiary),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'toggle') onToggleActive();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                          AppSpacing.gapHSm,
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            user.isActive ? Icons.lock_outline : Icons.lock_open_outlined,
                            size: 18,
                            color: user.isActive ? AppColors.error : AppColors.success,
                          ),
                          AppSpacing.gapHSm,
                          Text(user.isActive ? 'Khóa tài khoản' : 'Kích hoạt'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          AppSpacing.gapHSm,
                          Text('Xóa', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
