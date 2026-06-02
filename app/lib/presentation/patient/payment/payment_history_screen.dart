import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/payment_model.dart';
import 'package:doctor_booking_app/data/repositories/payment_repository.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';
import 'package:intl/intl.dart';

/// Provider: fetch payment history for the current logged-in user only
final userPaymentHistoryProvider = FutureProvider<List<PaymentModel>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  return ref.watch(paymentRepositoryProvider).getPaymentHistory(userId);
});

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final paymentsAsync = ref.watch(userPaymentHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử thanh toán')),
      body: paymentsAsync.when(
        data: (payments) {
          if (payments.isEmpty) {
            return const AppEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Chưa có giao dịch nào',
              subtitle: 'Lịch sử thanh toán sẽ hiển thị ở đây sau khi bạn đặt lịch khám',
            );
          }

          // Calculate total
          final totalAmount = payments
              .where((p) => p.isSuccess)
              .fold<double>(0, (sum, p) => sum + p.amount);
          final totalCount = payments.length;
          final formatter = NumberFormat('#,###', 'vi_VN');

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userPaymentHistoryProvider),
            child: Column(children: [
              // Total card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: AppDecorations.gradientPrimary,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Tổng chi phí', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  AppSpacing.gapXs,
                  Text(
                    '${formatter.format(totalAmount)}đ',
                    style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.gapXs,
                  Text('$totalCount giao dịch', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                ]),
              ),
              Expanded(child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final p = payments[index];
                  final isRefunded = p.status == PaymentStatus.refunded;
                  final isFailed = p.status == PaymentStatus.failed;
                  final isPending = p.isPending;

                  final Color color;
                  final String statusText;
                  final IconData statusIcon;

                  if (isRefunded) {
                    color = AppColors.accent;
                    statusText = 'Hoàn tiền';
                    statusIcon = Icons.undo_rounded;
                  } else if (isFailed) {
                    color = AppColors.error;
                    statusText = 'Thất bại';
                    statusIcon = Icons.cancel_rounded;
                  } else if (isPending) {
                    color = AppColors.statusPending;
                    statusText = 'Đang xử lý';
                    statusIcon = Icons.hourglass_bottom_rounded;
                  } else {
                    color = AppColors.success;
                    statusText = 'Thành công';
                    statusIcon = Icons.check_circle_rounded;
                  }

                  final dateStr = '${p.createdAt.day.toString().padLeft(2, '0')}/${p.createdAt.month.toString().padLeft(2, '0')}/${p.createdAt.year}';

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: AppDecorations.card,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: AppDecorations.iconContainer(color),
                            child: Icon(statusIcon, color: color, size: 22),
                          ),
                          AppSpacing.gapHMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Thanh toán lịch hẹn', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                AppSpacing.gapXs,
                                Text('$dateStr • ${p.methodDisplayName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${formatter.format(p.amount)}đ', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              AppSpacing.gapXs,
                              Text(
                                statusText,
                                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )),
            ]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppEmptyState(
          icon: Icons.error_outline,
          title: 'Không tải được lịch sử thanh toán',
          subtitle: '$e',
          actionText: 'Thử lại',
          onAction: () => ref.invalidate(userPaymentHistoryProvider),
        ),
      ),
    );
  }
}
