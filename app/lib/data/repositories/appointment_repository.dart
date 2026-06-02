import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/core/di/di_providers.dart';
import 'package:doctor_booking_app/core/error/failures.dart';
import 'package:doctor_booking_app/data/models/appointment_model.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository(ref.watch(supabaseClientProvider));
});

class AppointmentRepository {
  final SupabaseClient _client;

  AppointmentRepository(this._client);

  /// Get appointments for a patient
  Future<List<AppointmentModel>> getPatientAppointments(String patientId) async {
    try {
      final data = await _client
          .from('appointments')
          .select('*, doctors(*, users(full_name, avatar_url), specialities(name, name_vi))')
          .eq('patient_id', patientId)
          .order('start_time', ascending: false);

      return (data as List).map((e) => AppointmentModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Get appointments for a doctor
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId) async {
    try {
      final data = await _client
          .from('appointments')
          .select('*, patient:users!appointments_patient_id_fkey(full_name, avatar_url)')
          .eq('doctor_id', doctorId)
          .order('start_time', ascending: true);

      return (data as List).map((e) => AppointmentModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Create a new appointment
  Future<AppointmentModel> createAppointment(AppointmentModel appointment) async {
    try {
      // Check slot availability
      final existing = await _client
          .from('appointments')
          .select('id')
          .eq('doctor_id', appointment.doctorId)
          .eq('start_time', appointment.startTime.toIso8601String())
          .neq('status', 'cancelled');

      if ((existing as List).isNotEmpty) {
        throw const ValidationFailure('Slot này đã được đặt, vui lòng chọn slot khác');
      }

      // Check patient limit (max 5 active)
      final activeCount = await _client
          .from('appointments')
          .select('id')
          .eq('patient_id', appointment.patientId)
          .inFilter('status', ['pending', 'confirmed']);

      if ((activeCount as List).length >= 5) {
        throw const ValidationFailure('Bạn đã có tối đa 5 lịch hẹn đang hoạt động');
      }

      final data = await _client
          .from('appointments')
          .insert(appointment.toInsertJson())
          .select()
          .single();

      return AppointmentModel.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const ValidationFailure('Slot vừa bị đặt, vui lòng chọn lại');
      }
      throw ServerFailure(e.message);
    }
  }

  /// Cancel an appointment
  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      await _client.from('appointments').update({
        'status': 'cancelled',
        'cancellation_reason': reason,
      }).eq('id', appointmentId);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Update appointment status (for doctors)
  Future<void> updateStatus(String appointmentId, AppointmentStatus status) async {
    try {
      await _client.from('appointments').update({
        'status': status.name,
      }).eq('id', appointmentId);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Get available time slots for a doctor on a specific date
  Future<List<DateTime>> getAvailableSlots(String doctorId, DateTime date) async {
    try {
      // Get booked slots for the day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final booked = await _client
          .from('appointments')
          .select('start_time')
          .eq('doctor_id', doctorId)
          .gte('start_time', startOfDay.toIso8601String())
          .lt('start_time', endOfDay.toIso8601String())
          .neq('status', 'cancelled');

      final bookedTimes = (booked as List)
          .map((e) => DateTime.parse(e['start_time'] as String))
          .toSet();

      // Generate 30-min slots from 8:00 to 17:00
      final slots = <DateTime>[];
      for (var hour = 8; hour < 17; hour++) {
        for (var min = 0; min < 60; min += 30) {
          final slot = DateTime(date.year, date.month, date.day, hour, min);
          if (!bookedTimes.contains(slot) && slot.isAfter(DateTime.now())) {
            slots.add(slot);
          }
        }
      }
      return slots;
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
