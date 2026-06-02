import 'package:equatable/equatable.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled, noShow }
enum ConsultationType { inPerson, video }

class AppointmentModel extends Equatable {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime bookingDate;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;
  final ConsultationType consultationType;
  final String? reason;
  final String? notes;
  final String? cancellationReason;
  final DateTime createdAt;
  // Joined fields
  final String? doctorName;
  final String? doctorAvatar;
  final String? specialityName;
  final String? patientName;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    this.status = AppointmentStatus.pending,
    this.consultationType = ConsultationType.inPerson,
    this.reason,
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    this.doctorName,
    this.doctorAvatar,
    this.specialityName,
    this.patientName,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctors'] as Map<String, dynamic>?;
    final doctorUser = doctor?['users'] as Map<String, dynamic>?;
    final speciality = doctor?['specialities'] as Map<String, dynamic>?;
    final patient = json['patient'] as Map<String, dynamic>?;

    return AppointmentModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      doctorId: json['doctor_id'] as String,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: _parseStatus(json['status'] as String?),
      consultationType: json['consultation_type'] == 'video'
          ? ConsultationType.video
          : ConsultationType.inPerson,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      doctorName: doctorUser?['full_name'] as String?,
      doctorAvatar: doctorUser?['avatar_url'] as String?,
      specialityName: speciality?['name_vi'] as String?,
      patientName: patient?['full_name'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'patient_id': patientId,
    'doctor_id': doctorId,
    'booking_date': bookingDate.toIso8601String().split('T')[0],
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'status': status.name,
    'consultation_type': consultationType == ConsultationType.video ? 'video' : 'in_person',
    'reason': reason,
    'notes': notes,
  };

  static AppointmentStatus _parseStatus(String? s) => switch (s) {
    'confirmed' => AppointmentStatus.confirmed,
    'completed' => AppointmentStatus.completed,
    'cancelled' => AppointmentStatus.cancelled,
    'no_show' => AppointmentStatus.noShow,
    _ => AppointmentStatus.pending,
  };

  bool get isPending => status == AppointmentStatus.pending;
  bool get isConfirmed => status == AppointmentStatus.confirmed;
  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isCancelled => status == AppointmentStatus.cancelled;
  bool get isVideo => consultationType == ConsultationType.video;
  bool get isUpcoming => startTime.isAfter(DateTime.now()) && !isCancelled;

  AppointmentModel copyWith({AppointmentStatus? status, String? cancellationReason}) {
    return AppointmentModel(
      id: id, patientId: patientId, doctorId: doctorId,
      bookingDate: bookingDate, startTime: startTime, endTime: endTime,
      status: status ?? this.status,
      consultationType: consultationType, reason: reason,
      notes: notes, cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt, doctorName: doctorName, doctorAvatar: doctorAvatar,
      specialityName: specialityName, patientName: patientName,
    );
  }

  @override
  List<Object?> get props => [id, patientId, doctorId, status];
}
