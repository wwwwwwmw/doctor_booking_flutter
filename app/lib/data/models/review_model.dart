import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String? appointmentId;
  final String patientId;
  final String doctorId;
  final int rating;
  final String? comment;
  final bool isAnonymous;
  final DateTime createdAt;
  // Joined
  final String? patientName;
  final String? patientAvatar;

  const ReviewModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.rating,
    this.appointmentId,
    this.comment,
    this.isAnonymous = false,
    required this.createdAt,
    this.patientName,
    this.patientAvatar,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final patient = json['users'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id'] as String,
      appointmentId: json['appointment_id'] as String?,
      patientId: json['patient_id'] as String,
      doctorId: json['doctor_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      patientName: patient?['full_name'] as String?,
      patientAvatar: patient?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'appointment_id': appointmentId,
    'patient_id': patientId,
    'doctor_id': doctorId,
    'rating': rating,
    'comment': comment,
    'is_anonymous': isAnonymous,
  };

  String get displayName => isAnonymous ? 'Ẩn danh' : (patientName ?? 'Bệnh nhân');

  @override
  List<Object?> get props => [id, patientId, doctorId, rating];
}
