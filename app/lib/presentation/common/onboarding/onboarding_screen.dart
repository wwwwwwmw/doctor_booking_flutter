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

  static const _pages = [
    _OnboardingData(
      icon: Icons.local_hospital_rounded,
      color: AppColors.primary,
      bgColor: AppColors.primarySurface,
      title: 'Đặt lịch dễ dàng',
      subtitle:
          'Tìm bác sĩ phù hợp và đặt lịch khám chỉ với vài thao tác đơn giản',
    ),
    _OnboardingData(
      icon: Icons.videocam_rounded,
      color: AppColors.success,
      bgColor: AppColors.successLight,
      title: 'Khám bệnh từ xa',
      subtitle:
          'Video call trực tiếp với bác sĩ mọi lúc mọi nơi, tiết kiệm thời gian',
    ),
    _OnboardingData(
      icon: Icons.chat_bubble_rounded,
      color: AppColors.accent,
      bgColor: AppColors.accentSurface,
      title: 'Chat trực tiếp',
      subtitle:
          'Nhắn tin với bác sĩ để được tư vấn và theo dõi sức khỏe thường xuyên',
    ),
    _OnboardingData(
      icon: Icons.shield_rounded,
      color: AppColors.secondary,
      bgColor: AppColors.secondarySurface,
      title: 'An toàn & Bảo mật',
      subtitle:
          'Dữ liệu y tế được mã hóa và bảo vệ theo tiêu chuẩn quốc tế',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: 400.ms, curve: Curves.easeInOut);
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive sizes based on available space
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;
            final isSmallScreen = screenHeight < 600;
            final iconSize = (screenWidth * 0.35).clamp(100.0, 180.0);
            final innerIconSize = iconSize * 0.75;
            final iconSymbolSize = (iconSize * 0.35).clamp(32.0, 60.0);
            final titleFontSize = (screenWidth * 0.065).clamp(20.0, 28.0);
            final subtitleFontSize = (screenWidth * 0.038).clamp(13.0, 16.0);
            final horizontalPadding = (screenWidth * 0.08).clamp(20.0, 48.0);

            return Column(
              children: [
                // ── Top bar: dots + skip ──
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isSmallScreen ? 4 : 8,
                  ),
                  child: Row(
                    children: [
                      // Dot indicators
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 6),
                            width: i == _currentPage ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: i == _currentPage
                                  ? AppColors.primaryGradient
                                  : null,
                              color:
                                  i == _currentPage ? null : AppColors.border,
                              borderRadius: AppSpacing.borderRadiusRound,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Skip button
                      TextButton(
                        onPressed: _goToLogin,
                        child: const Text('Bỏ qua'),
                      ),
                    ],
                  ),
                ),

                // ── Page content ──
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight -
                                (isSmallScreen ? 100 : 140),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: isSmallScreen ? 12 : 24),
                              // Icon with double ring — responsive
                              Container(
                                width: iconSize,
                                height: iconSize,
                                decoration: BoxDecoration(
                                  color: page.bgColor.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Container(
                                    width: innerIconSize,
                                    height: innerIconSize,
                                    decoration: BoxDecoration(
                                      color: page.bgColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      page.icon,
                                      size: iconSymbolSize,
                                      color: page.color,
                                    ),
                                  ),
                                ),
                              )
                                  .animate(key: ValueKey('icon_$index'))
                                  .scaleXY(
                                    begin: 0.7,
                                    end: 1,
                                    duration: 600.ms,
                                    curve: Curves.elasticOut,
                                  )
                                  .fadeIn(),
                              SizedBox(height: isSmallScreen ? 24 : 40),
                              // Title
                              Text(
                                page.title,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                                  .animate(key: ValueKey('t_$index'))
                                  .fadeIn(delay: 200.ms)
                                  .slideY(begin: 0.1),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              // Subtitle
                              Text(
                                page.subtitle,
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              )
                                  .animate(key: ValueKey('s_$index'))
                                  .fadeIn(delay: 400.ms),
                              SizedBox(height: isSmallScreen ? 12 : 24),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Bottom: Next/Start button ──
                Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: isSmallScreen ? 12 : 24,
                    top: 4,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(isLast ? 'Bắt đầu' : 'Tiếp tục'),
                          const SizedBox(width: 8),
                          Icon(
                            isLast
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
  const _OnboardingData({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });
}
