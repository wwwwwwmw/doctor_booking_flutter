import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/presentation/patient/home/patient_home_screen.dart';
import 'package:doctor_booking_app/presentation/doctor/home/doctor_home_screen.dart';
import 'package:doctor_booking_app/presentation/admin/dashboard/admin_dashboard_screen.dart';
import 'package:doctor_booking_app/presentation/common/auth/register_screen.dart';
import 'package:doctor_booking_app/presentation/common/auth/forgot_password_screen.dart';
import 'package:doctor_booking_app/presentation/common/auth/pending_approval_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;

      // Lấy role + is_active từ bảng users
      String role = 'patient';
      bool isActive = true;
      try {
        final userData = await Supabase.instance.client
            .from('users')
            .select('role, is_active')
            .eq('id', response.user!.id)
            .maybeSingle();
        role = userData?['role'] as String? ?? 'patient';
        isActive = userData?['is_active'] as bool? ?? true;
      } catch (_) {
        // Fallback: check user_metadata
        role = response.user?.userMetadata?['role'] as String? ?? 'patient';
      }

      if (!mounted) return;

      // Doctor chưa được duyệt → chặn đăng nhập
      if (role == 'doctor' && !isActive) {
        await Supabase.instance.client.auth.signOut();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
        );
        return;
      }

      // Route theo role
      final Widget destination;
      if (role == 'admin') {
        destination = const AdminDashboardScreen();
      } else if (role == 'doctor') {
        destination = const DoctorHomeScreen();
      } else {
        destination = const PatientHomeScreen();
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.doctorbooking://login-callback/',
      );
    } catch (e) {
      if (!mounted) return;
      String message = 'Đăng nhập Google thất bại';
      if (e.toString().contains('ACTIVITY_NOT_FOUND')) {
        message = 'Không tìm thấy trình duyệt. Vui lòng cài đặt Chrome hoặc trình duyệt web.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // Logo
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset('assets/images/app_logo.png', fit: BoxFit.contain),
                  ),
                ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                AppSpacing.gapXxl,
                Text(
                  'Chào mừng trở lại',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
                AppSpacing.gapSm,
                Text(
                  'Đăng nhập để đặt lịch khám bệnh',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 36),

                // Email field
                TextFormField(
                  key: const Key('email_field'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'email@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Email không hợp lệ';
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.05),
                AppSpacing.gapLg,

                // Password field
                TextFormField(
                  key: const Key('password_field'),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                    return null;
                  },
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.05),
                AppSpacing.gapSm,

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: const Text('Quên mật khẩu?'),
                  ),
                ),
                AppSpacing.gapLg,

                // Login button
                FilledButton(
                  key: const Key('login_button'),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Đăng nhập'),
                ).animate().fadeIn(delay: 600.ms),
                AppSpacing.gapXxl,

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('hoặc', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                AppSpacing.gapXxl,

                // Google sign in
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Đăng nhập với Google'),
                ).animate().fadeIn(delay: 700.ms),
                AppSpacing.gapXxxl,

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Chưa có tài khoản? ', style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text('Đăng ký ngay'),
                    ),
                  ],
                ),
                AppSpacing.gapXxl,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
