import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/core/di/di_providers.dart';
import 'package:doctor_booking_app/core/error/failures.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

/// Model for a notification item
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type; // appointment, reminder, cancellation, review, system
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String? ?? 'system',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Provider: fetch notifications for the current logged-in user only
final userNotificationsProvider = FutureProvider<List<NotificationItem>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = Supabase.instance.client.auth.currentUser!.id;

  try {
    final data = await client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);

    return (data as List).map((e) => NotificationItem.fromJson(e)).toList();
  } on PostgrestException catch (e) {
    throw ServerFailure(e.message);
  }
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getIcon(String type) => switch (type) {
    'appointment' => Icons.calendar_today_rounded,
    'chat' => Icons.chat_bubble_rounded,
    'reminder' => Icons.alarm_rounded,
    'payment' => Icons.payment_rounded,
    'review' => Icons.star_rounded,
    'cancellation' => Icons.cancel_rounded,
    _ => Icons.notifications_rounded,
  };

  Color _getColor(String type) => switch (type) {
    'appointment' => AppColors.primary,
    'chat' => AppColors.success,
    'reminder' => AppColors.accent,
    'payment' => AppColors.secondary,
    'review' => AppColors.statusPending,
    'cancellation' => AppColors.error,
    _ => AppColors.textTertiary,
  };

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final userId = Supabase.instance.client.auth.currentUser!.id;
                await ref.read(supabaseClientProvider)
                    .from('notifications')
                    .update({'is_read': true})
                    .eq('user_id', userId)
                    .eq('is_read', false);
                ref.invalidate(userNotificationsProvider);
              } catch (_) {}
            },
            child: const Text('Đọc tất cả'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const AppEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'Chưa có thông báo nào',
              subtitle: 'Thông báo sẽ xuất hiện khi có hoạt động mới',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userNotificationsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => AppDecorations.thinDivider,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isUnread = !notif.isRead;
                final color = _getColor(notif.type);

                return Material(
                  color: isUnread ? AppColors.primarySurface.withValues(alpha: 0.3) : Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      // Mark as read on tap
                      if (isUnread) {
                        try {
                          await ref.read(supabaseClientProvider)
                              .from('notifications')
                              .update({'is_read': true})
                              .eq('id', notif.id);
                          ref.invalidate(userNotificationsProvider);
                        } catch (_) {}
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: AppDecorations.iconContainer(color),
                            child: Icon(_getIcon(notif.type), color: color, size: 20),
                          ),
                          AppSpacing.gapHMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notif.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                AppSpacing.gapXs,
                                Text(
                                  notif.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                                AppSpacing.gapXs,
                                Text(
                                  _formatTime(notif.createdAt),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8, height: 8,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppEmptyState(
          icon: Icons.error_outline,
          title: 'Không tải được thông báo',
          subtitle: '$e',
          actionText: 'Thử lại',
          onAction: () => ref.invalidate(userNotificationsProvider),
        ),
      ),
    );
  }
}
