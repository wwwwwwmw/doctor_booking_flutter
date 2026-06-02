import 'package:flutter/material.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';

class WriteReviewScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String? appointmentId;

  const WriteReviewScreen({super.key, required this.doctorId, required this.doctorName, this.appointmentId});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isAnonymous = false;
  bool _isLoading = false;

  @override
  void dispose() { _commentController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá bác sĩ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Doctor info
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primarySurface),
              child: Center(
                child: Text(widget.doctorName[0], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ),
            AppSpacing.gapMd,
            Text(widget.doctorName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            AppSpacing.gapXxxl,

            // Rating stars
            const Text('Bạn đánh giá thế nào?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            AppSpacing.gapMd,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 48,
                    color: i < _rating ? Colors.amber.shade700 : AppColors.textTertiary,
                  ),
                ),
              )),
            ),
            if (_rating > 0) ...[
              AppSpacing.gapSm,
              Text(
                ['', 'Rất tệ', 'Tệ', 'Bình thường', 'Tốt', 'Tuyệt vời'][_rating],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _rating >= 4 ? AppColors.success : _rating >= 3 ? AppColors.accent : AppColors.error,
                ),
              ),
            ],
            AppSpacing.gapXxl,

            // Comment
            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Chia sẻ trải nghiệm của bạn (tùy chọn)...',
                alignLabelWithHint: true,
              ),
            ),
            AppSpacing.gapMd,

            // Anonymous toggle
            SwitchListTile(
              title: const Text('Đánh giá ẩn danh', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: const Text('Tên bạn sẽ không hiển thị', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              value: _isAnonymous,
              onChanged: (v) => setState(() => _isAnonymous = v),
              contentPadding: EdgeInsets.zero,
              activeTrackColor: AppColors.primary,
            ),
            AppSpacing.gapXxl,

            // Submit
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _rating == 0 || _isLoading ? null : () async {
                  setState(() => _isLoading = true);
                  await Future.delayed(const Duration(seconds: 1));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Cảm ơn bạn đã đánh giá!'), backgroundColor: AppColors.success),
                  );
                  Navigator.pop(context, true);
                },
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Gửi đánh giá'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
