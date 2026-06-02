import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/presentation/common/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = [
    _OnboardingData(
      icon: Icons.local_hospital_rounded,
      color: AppColors.primary,
      bgColor: AppColors.primarySurface,
      title: 'Đặt lịch dễ dàng',
      subtitle: 'Tìm bác sĩ phù hợp và đặt lịch khám chỉ với vài thao tác đơn giản',
    ),
    _OnboardingData(
      icon: Icons.videocam_rounded,
      color: AppColors.success,
      bgColor: AppColors.successLight,
      title: 'Khám bệnh từ xa',
      subtitle: 'Video call trực tiếp với bác sĩ mọi lúc mọi nơi, tiết kiệm thời gian',
    ),
    _OnboardingData(
      icon: Icons.chat_bubble_rounded,
      color: AppColors.accent,
      bgColor: AppColors.accentSurface,
      title: 'Chat trực tiếp',
      subtitle: 'Nhắn tin với bác sĩ để được tư vấn và theo dõi sức khỏe thường xuyên',
    ),
    _OnboardingData(
      icon: Icons.shield_rounded,
      color: AppColors.secondary,
      bgColor: AppColors.secondarySurface,
      title: 'An toàn & Bảo mật',
      subtitle: 'Dữ liệu y tế được mã hóa và bảo vệ theo tiêu chuẩn quốc tế',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: 400.ms, curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.lg, top: AppSpacing.sm),
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Bỏ qua'),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with double ring
                        Container(
                          width: 160, height: 160,
                          decoration: BoxDecoration(
                            color: page.bgColor.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 120, height: 120,
                              decoration: BoxDecoration(
                                color: page.bgColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(page.icon, size: 56, color: page.color),
                            ),
                          ),
                        )
                            .animate(key: ValueKey(index))
                            .scaleXY(begin: 0.7, end: 1, duration: 600.ms, curve: Curves.elasticOut)
                            .fadeIn(),
                        AppSpacing.gapHuge,
                        Text(
                          page.title,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3),
                          textAlign: TextAlign.center,
                        ).animate(key: ValueKey('t$index')).fadeIn(delay: 200.ms).slideY(begin: 0.1),
                        AppSpacing.gapMd,
                        Text(
                          page.subtitle,
                          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
                          textAlign: TextAlign.center,
                        ).animate(key: ValueKey('s$index')).fadeIn(delay: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicators + Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Row(
                children: [
                  // Dots
                  Row(children: List.generate(_pages.length, (i) => AnimatedContainer(
                    duration: 300.ms,
                    margin: const EdgeInsets.only(right: 8),
                    width: i == _currentPage ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: i == _currentPage ? AppColors.primaryGradient : null,
                      color: i == _currentPage ? null : AppColors.border,
                      borderRadius: AppSpacing.borderRadiusRound,
                    ),
                  ))),
                  const Spacer(),
                  // Button
                  FilledButton(
                    onPressed: _next,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isLast ? 'Bắt đầu' : 'Tiếp'),
                        AppSpacing.gapHSm,
                        Icon(isLast ? Icons.check_rounded : Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String subtitle;
  const _OnboardingData({required this.icon, required this.color, required this.bgColor, required this.title, required this.subtitle});
}
