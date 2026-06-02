import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/config/theme/app_colors.dart';
import 'package:doctor_booking_app/config/theme/app_spacing.dart';
import 'package:doctor_booking_app/config/theme/app_decorations.dart';
import 'package:doctor_booking_app/data/models/chat_model.dart';
import 'package:doctor_booking_app/data/repositories/chat_repository.dart';
import 'package:doctor_booking_app/presentation/chat/chat_conversation_screen.dart';
import 'package:doctor_booking_app/presentation/common/widgets/shared_widgets.dart';

/// Provider that fetches conversations for the current logged-in user only
final userConversationsProvider = FutureProvider<List<ChatConversationModel>>((ref) {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  return ref.watch(chatRepositoryProvider).getConversations(userId);
});

class ChatInboxScreen extends ConsumerWidget {
  const ChatInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(userConversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        actions: [IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {})],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const AppEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chưa có cuộc trò chuyện',
              subtitle: 'Đặt lịch khám để bắt đầu chat với bác sĩ',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userConversationsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: conversations.length,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(left: 76),
                child: AppDecorations.thinDivider,
              ),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                final displayName = conv.otherUserName ?? 'Người dùng';
                final hasUnread = conv.unreadCount > 0;

                return Material(
                  color: hasUnread ? AppColors.primarySurface.withValues(alpha: 0.2) : Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChatConversationScreen(
                        conversationId: conv.id,
                        otherUserName: displayName,
                      ),
                    )),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primarySurface),
                            child: Center(
                              child: Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                            ),
                          ),
                          AppSpacing.gapHMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: TextStyle(fontSize: 14, fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500),
                                ),
                                AppSpacing.gapXs,
                                Text(
                                  conv.lastMessageContent ?? 'Bắt đầu trò chuyện',
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: hasUnread ? AppColors.textPrimary : AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppSpacing.gapHSm,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTime(conv.lastMessageAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: hasUnread ? AppColors.primary : AppColors.textTertiary,
                                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                              if (hasUnread) ...[
                                AppSpacing.gapXs,
                                Container(
                                  width: 20, height: 20,
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      conv.unreadCount > 9 ? '9+' : '${conv.unreadCount}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
          icon: Icons.error_outline_rounded,
          title: 'Không tải được tin nhắn',
          subtitle: '$e',
          actionText: 'Thử lại',
          onAction: () => ref.invalidate(userConversationsProvider),
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút';
    if (diff.inDays < 1) return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return 'T${time.weekday + 1}';
    return '${time.day}/${time.month}';
  }
}
