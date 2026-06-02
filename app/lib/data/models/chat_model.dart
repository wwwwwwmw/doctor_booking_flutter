import 'package:equatable/equatable.dart';

class ChatConversationModel extends Equatable {
  final String id;
  final String? appointmentId;
  final String patientId;
  final String doctorId;
  final String status;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  // Joined
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? lastMessageContent;
  final int unreadCount;

  const ChatConversationModel({
    required this.id,
    this.appointmentId,
    required this.patientId,
    required this.doctorId,
    this.status = 'active',
    this.lastMessageAt,
    required this.createdAt,
    this.otherUserName,
    this.otherUserAvatar,
    this.lastMessageContent,
    this.unreadCount = 0,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final patientId = json['patient_id'] as String;
    final doctorId = json['doctor_id'] as String;

    // Lấy tên người kia từ fields được repository populate
    String? otherName = json['_other_name'] as String?;
    String? otherAvatar = json['_other_avatar'] as String?;
    String? lastMessage = json['_last_message'] as String?;

    // Fallback: thử parse từ join data (nếu có)
    if (otherName == null && currentUserId != null) {
      final patientUser = json['patient'] as Map<String, dynamic>?;
      final doctorUser = json['doctor'] as Map<String, dynamic>?;
      if (currentUserId == patientId) {
        otherName = doctorUser?['full_name'] as String?;
        otherAvatar = doctorUser?['avatar_url'] as String?;
      } else {
        otherName = patientUser?['full_name'] as String?;
        otherAvatar = patientUser?['avatar_url'] as String?;
      }
    }

    return ChatConversationModel(
      id: json['id'] as String,
      appointmentId: json['appointment_id'] as String?,
      patientId: patientId,
      doctorId: doctorId,
      status: json['status'] as String? ?? 'active',
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      otherUserName: otherName,
      otherUserAvatar: otherAvatar,
      lastMessageContent: lastMessage,
    );
  }

  bool get isActive => status == 'active';

  @override
  List<Object?> get props => [id, patientId, doctorId];
}

class ChatMessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String messageType; // text | image | file
  final String? fileUrl;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    this.fileUrl,
    this.isRead = false,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      fileUrl: json['file_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'conversation_id': conversationId,
    'sender_id': senderId,
    'content': content,
    'message_type': messageType,
    'file_url': fileUrl,
  };

  bool isMine(String userId) => senderId == userId;
  bool get isText => messageType == 'text';
  bool get isImage => messageType == 'image';
  bool get isFile => messageType == 'file';

  @override
  List<Object?> get props => [id, conversationId, senderId, createdAt];
}
