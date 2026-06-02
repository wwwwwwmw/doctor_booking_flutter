import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/core/di/di_providers.dart';
import 'package:doctor_booking_app/core/error/failures.dart';
import 'package:doctor_booking_app/data/models/doctor_model.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository(ref.watch(supabaseClientProvider));
});

class DoctorRepository {
  final SupabaseClient _client;

  DoctorRepository(this._client);

  /// Get all verified doctors
  Future<List<DoctorModel>> getDoctors({String? specialityId, String? search}) async {
    try {
      var query = _client
          .from('doctors')
          .select('*, users(full_name, avatar_url, email), specialities(name, name_vi, icon)')
          .eq('is_verified', true);

      if (specialityId != null) {
        query = query.eq('speciality_id', specialityId);
      }

      final data = await query.order('rating_avg', ascending: false);
      var doctors = (data as List).map((e) => DoctorModel.fromJson(e)).toList();

      // Client-side search filter
      if (search != null && search.isNotEmpty) {
        final s = search.toLowerCase();
        doctors = doctors.where((d) =>
          (d.fullName?.toLowerCase().contains(s) ?? false) ||
          (d.specialityName?.toLowerCase().contains(s) ?? false) ||
          (d.specialityNameVi?.toLowerCase().contains(s) ?? false) ||
          (d.hospital?.toLowerCase().contains(s) ?? false)
        ).toList();
      }

      return doctors;
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Get doctor by ID
  Future<DoctorModel> getDoctorById(String doctorId) async {
    try {
      final data = await _client
          .from('doctors')
          .select('*, users(full_name, avatar_url, email, phone), specialities(name, name_vi, icon)')
          .eq('id', doctorId)
          .single();

      return DoctorModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Get all specialities
  Future<List<SpecialityModel>> getSpecialities() async {
    try {
      final data = await _client
          .from('specialities')
          .select()
          .eq('is_active', true)
          .order('name_vi');

      return (data as List).map((e) => SpecialityModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Get top rated doctors
  Future<List<DoctorModel>> getTopDoctors({int limit = 10}) async {
    try {
      final data = await _client
          .from('doctors')
          .select('*, users(full_name, avatar_url), specialities(name, name_vi)')
          .eq('is_verified', true)
          .gt('rating_count', 0)
          .order('rating_avg', ascending: false)
          .limit(limit);

      return (data as List).map((e) => DoctorModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
