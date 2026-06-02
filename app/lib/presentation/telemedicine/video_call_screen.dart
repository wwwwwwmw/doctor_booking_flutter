import 'package:flutter/material.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String doctorName;
  const VideoCallScreen({super.key, required this.channelName, required this.doctorName});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeaker = true;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Simulate call timer
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _duration += const Duration(seconds: 1));
      return true;
    });
  }

  String get _durationText {
    final min = _duration.inMinutes.toString().padLeft(2, '0');
    final sec = (_duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          // Remote video background (dark gradient)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0D0D1A),
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                ],
              ),
            ),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Doctor avatar with animated ring
                Container(
                  width: 130, height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 3),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Text(widget.doctorName[0], style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                AppSpacing.gapLg,
                Text(widget.doctorName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
                AppSpacing.gapSm,
                Text(_durationText, style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.6))),
              ]),
            ),
          ),

          // Local video preview (top right) with rounded design
          Positioned(top: 60, right: AppSpacing.lg,
            child: Container(
              width: 120, height: 160,
              decoration: BoxDecoration(
                color: _isCameraOff ? const Color(0xFF2A2A3E) : const Color(0xFF3A4A5E),
                borderRadius: AppSpacing.borderRadiusLg,
                border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: _isCameraOff
                  ? const Center(child: Icon(Icons.videocam_off_rounded, color: Colors.white38, size: 32))
                  : const Center(child: Icon(Icons.person_rounded, color: Colors.white38, size: 48)),
            ),
          ),

          // Top bar — call status badge
          Positioned(top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF00C853), Color(0xFF00E676)]),
                      borderRadius: AppSpacing.borderRadiusRound,
                      boxShadow: [BoxShadow(color: const Color(0xFF00C853).withValues(alpha: 0.3), blurRadius: 8)],
                    ),
                    child: Row(children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      AppSpacing.gapHSm,
                      Text(_durationText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    ]),
                  ),
                  const Spacer(),
                  _TopBarButton(icon: Icons.switch_camera_rounded, onTap: () {}),
                  AppSpacing.gapHSm,
                  _TopBarButton(icon: Icons.more_vert_rounded, onTap: () {}),
                ]),
              ),
            ),
          ),

          // Bottom controls with glassmorphism
          Positioned(bottom: 0, left: 0, right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, const Color(0xFF0D0D1A).withValues(alpha: 0.9), const Color(0xFF0D0D1A)]),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  _CallButton(
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: _isMuted ? 'Bật mic' : 'Tắt mic',
                    active: !_isMuted,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),
                  _CallButton(
                    icon: _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                    label: _isCameraOff ? 'Bật cam' : 'Tắt cam',
                    active: !_isCameraOff,
                    onTap: () => setState(() => _isCameraOff = !_isCameraOff),
                  ),
                  _CallButton(
                    icon: _isSpeaker ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    label: 'Loa',
                    active: _isSpeaker,
                    onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                  ),
                  _CallButton(icon: Icons.chat_rounded, label: 'Chat', active: true, onTap: () {}),
                  // End call — gradient red
                  GestureDetector(
                    onTap: () => _showEndCallDialog(context),
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF1744), Color(0xFFD50000)]),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: const Color(0xFFFF1744).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEndCallDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Kết thúc cuộc gọi?'),
      content: Text('Cuộc gọi đã diễn ra $_durationText'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tiếp tục')),
        FilledButton(
          onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Kết thúc'),
        ),
      ],
    ));
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopBarButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon; final String label; final bool active; final VoidCallback onTap;
  const _CallButton({required this.icon, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 50, height: 50,
          decoration: BoxDecoration(
            color: active ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.06),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: active ? 0.2 : 0.08), width: 1),
          ),
          child: Icon(icon, color: active ? Colors.white : Colors.white38, size: 22)),
        AppSpacing.gapSm,
        Text(label, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 11)),
      ]),
    );
  }
}
