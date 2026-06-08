import 'package:equatable/equatable.dart';

class DoctorModel extends Equatable {
  final String id;
  final String? specialityId;
  final String? hospital;
  final String? bio;
  final int experienceYears;
  final double consultationFee;
  final double ratingAvg;
  final int ratingCount;
  final bool isVerified;
  final bool isAvailable;
  final Map<String, dynamic>? workingHours;
  // Joined fields
  final String? fullName;
  final String? avatarUrl;
  final String? email;
  final String? specialityName;
  final String? specialityNameVi;

  const DoctorModel({
    required this.id,
    this.specialityId,
    this.hospital,
    this.bio,
    this.experienceYears = 0,
    this.consultationFee = 0,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.isVerified = false,
    this.isAvailable = true,
    this.workingHours,
    this.fullName,
    this.avatarUrl,
    this.email,
    this.specialityName,
    this.specialityNameVi,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>?;
    final speciality = json['specialities'] as Map<String, dynamic>?;

    return DoctorModel(
      id: json['id'] as String,
      specialityId: json['speciality_id'] as String?,
      hospital: json['hospital'] as String?,
      bio: json['bio'] as String?,
      experienceYears: json['experience_years'] as int? ?? 0,
      consultationFee: (json['consultation_fee'] as num?)?.toDouble() ?? 0,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
      ratingCount: json['rating_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      workingHours: json['working_hours'] as Map<String, dynamic>?,
      fullName: user?['full_name'] as String?,
      avatarUrl: user?['avatar_url'] as String?,
      email: user?['email'] as String?,
      specialityName: speciality?['name'] as String?,
      specialityNameVi: speciality?['name_vi'] as String?,
    );
  }

  String get displayFee => '${consultationFee.toStringAsFixed(0)}đ';
  String get displayRating => ratingAvg.toStringAsFixed(1);

  @override
  List<Object?> get props => [id, specialityId, ratingAvg];
}

class SpecialityModel extends Equatable {
  final String id;
  final String name;
  final String nameVi;
  final String? icon;
  final String? description;
  final bool isActive;

  const SpecialityModel({
    required this.id,
    required this.name,
    required this.nameVi,
    this.icon,
    this.description,
    this.isActive = true,
  });

  factory SpecialityModel.fromJson(Map<String, dynamic> json) {
    return SpecialityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameVi: json['name_vi'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
