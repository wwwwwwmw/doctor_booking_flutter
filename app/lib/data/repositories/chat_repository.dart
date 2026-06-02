import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/core/di/di_providers.dart';
import 'package:doctor_booking_app/core/error/failures.dart';
import 'package:doctor_booking_app/data/models/chat_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(supabaseClientProvider));
});

class ChatRepository {
  final SupabaseClient _client;

  ChatRepository(this._client);

  /// Get conversations for a user (with joined user names)
  Future<List<ChatConversationModel>> getConversations(String userId) async {
    try {
      // Lấy conversations với join đơn giản qua patient (users)
      // doctor_id cũng là users.id nên join được qua cùng bảng
      final data = await _client
          .from('chat_conversations')
          .select()
          .or('patient_id.eq.$userId,doctor_id.eq.$userId')
          .eq('status', 'active')
          .order('last_message_at', ascending: false);

      final conversations = <ChatConversationModel>[];
      for (final row in (data as List)) {
        // Xác định "người kia" là ai
        final patientId = row['patient_id'] as String;
        final doctorId = row['doctor_id'] as String;
        final otherId = (userId == patientId) ? doctorId : patientId;

        // Lấy tên người kia từ bảng users
        try {
          final otherUser = await _client
              .from('users')
              .select('full_name, avatar_url')
              .eq('id', otherId)
              .maybeSingle();

          row['_other_name'] = otherUser?['full_name'];
          row['_other_avatar'] = otherUser?['avatar_url'];
        } catch (_) {
          row['_other_name'] = null;
          row['_other_avatar'] = null;
        }

        // Lấy tin nhắn cuối cùng
        try {
          final lastMsg = await _client
              .from('chat_messages')
              .select('content')
              .eq('conversation_id', row['id'])
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          row['_last_message'] = lastMsg?['content'];
        } catch (_) {
          row['_last_message'] = null;
        }

        conversations.add(ChatConversationModel.fromJson(row, currentUserId: userId));
      }

      return conversations;
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Get or create conversation between patient and doctor
  Future<ChatConversationModel> getOrCreateConversation({
    required String patientId,
    required String doctorId,
    String? appointmentId,
  }) async {
    try {
      // Check existing
      final existing = await _client
          .from('chat_conversations')
          .select()
          .eq('patient_id', patientId)
          .eq('doctor_id', doctorId)
          .eq('status', 'active')
          .maybeSingle();

      if (existing != null) {
        return ChatConversationModel.fromJson(existing);
      }

      // Create new
      final data = await _client.from('chat_conversations').insert({
        'patient_id': patientId,
        'doctor_id': doctorId,
        'appointment_id': appointmentId,
        'status': 'active',
      }).select().single();

      return ChatConversationModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Get messages for a conversation
  Future<List<ChatMessageModel>> getMessages(String conversationId, {int limit = 50}) async {
    try {
      final data = await _client
          .from('chat_messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List).map((e) => ChatMessageModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Send a message
  Future<ChatMessageModel> sendMessage(ChatMessageModel message) async {
    try {
      final data = await _client
          .from('chat_messages')
          .insert(message.toInsertJson())
          .select()
          .single();

      // Update conversation last_message_at
      await _client.from('chat_conversations').update({
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', message.conversationId);

      return ChatMessageModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Subscribe to realtime messages
  Stream<ChatMessageModel> subscribeToMessages(String conversationId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map((rows) => rows.isNotEmpty ? ChatMessageModel.fromJson(rows.last) : throw const NotFoundFailure())
        .handleError((e) {});
  }

  /// Mark messages as read
  Future<void> markAsRead(String conversationId, String userId) async {
    try {
      await _client
          .from('chat_messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId)
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
