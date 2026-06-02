import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/presentation/telemedicine/video_call_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String doctorName;
  final String channelName;
  const WaitingRoomScreen({super.key, required this.doctorName, required this.channelName});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> with TickerProviderStateMixin {
  int _waitingSeconds = 0;
  bool _cameraReady = true;
  bool _micReady = true;

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _waitingSeconds++);
      return true;
    });
  }

  String get _waitTime {
    final min = (_waitingSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_waitingSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phòng chờ'), leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () => showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Rời phòng chờ?'),
          content: const Text('Bạn sẽ mất vị trí trong hàng đợi.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ở lại')),
            FilledButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('Rời đi')),
          ],
        )),
      )),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Doctor avatar with pulse
              Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primarySurface.withValues(alpha: 0.4),
                ),
                child: Center(
                  child: Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primarySurface),
                    child: Center(
                      child: Text(widget.doctorName[0], style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(end: 1.05, duration: 2000.ms),
              AppSpacing.gapLg,
              Text(widget.doctorName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              AppSpacing.gapSm,
              const Text('Đang chờ bác sĩ tham gia...', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              AppSpacing.gapMd,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: AppSpacing.borderRadiusRound),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                  AppSpacing.gapHSm,
                  Text('Đã chờ: $_waitTime', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                ]),
              ),
              AppSpacing.gapHuge,

              // Device check
              Container(
                decoration: AppDecorations.card,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kiểm tra thiết bị', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    AppSpacing.gapMd,
                    _DeviceCheck(icon: Icons.videocam_rounded, label: 'Camera', ready: _cameraReady, color: AppColors.primary,
                      onToggle: () => setState(() => _cameraReady = !_cameraReady)),
                    _DeviceCheck(icon: Icons.mic_rounded, label: 'Microphone', ready: _micReady, color: AppColors.accent,
                      onToggle: () => setState(() => _micReady = !_micReady)),
                    _DeviceCheck(icon: Icons.wifi_rounded, label: 'Kết nối mạng', ready: true, color: AppColors.success,
                      onToggle: () {}),
                  ],
                ),
              ),
              AppSpacing.gapXxl,

              // Join button
              SizedBox(width: double.infinity, child: FilledButton.icon(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (_) => VideoCallScreen(channelName: widget.channelName, doctorName: widget.doctorName))),
                icon: const Icon(Icons.videocam_rounded),
                label: const Text('Tham gia cuộc gọi'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceCheck extends StatelessWidget {
  final IconData icon; final String label; final bool ready; final Color color; final VoidCallback onToggle;
  const _DeviceCheck({required this.icon, required this.label, required this.ready, required this.color, required this.onToggle});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: AppDecorations.iconContainer(ready ? color : AppColors.textTertiary), child: Icon(icon, size: 16, color: ready ? color : AppColors.textTertiary)),
          AppSpacing.gapHMd,
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Switch(value: ready, onChanged: (_) => onToggle(), activeTrackColor: AppColors.primary),
        ],
      ),
    );
  }
}
