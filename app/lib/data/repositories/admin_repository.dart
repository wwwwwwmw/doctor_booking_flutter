import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/core/di/di_providers.dart';
import 'package:doctor_booking_app/core/error/failures.dart';
import 'package:doctor_booking_app/data/models/user_model.dart';
import 'package:doctor_booking_app/data/models/doctor_model.dart';

/// Admin repository provider
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(supabaseClientProvider));
});

/// Model for admin dashboard stats
class AdminStats {
  final int totalUsers;
  final int totalDoctors;
  final int totalAppointments;
  final double totalRevenue;
  final int pendingDoctors;
  final int todayAppointments;

  const AdminStats({
    required this.totalUsers,
    required this.totalDoctors,
    required this.totalAppointments,
    required this.totalRevenue,
    required this.pendingDoctors,
    required this.todayAppointments,
  });
}

/// Model for weekly chart data
class DailyAppointmentStat {
  final String dayLabel;
  final int count;

  const DailyAppointmentStat({required this.dayLabel, required this.count});
}

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  /// Get admin dashboard statistics from DB
  Future<AdminStats> getAdminStats() async {
    try {
      // Count total users (excluding admins)
      final usersData = await _client
          .from('users')
          .select('id')
          .neq('role', 'admin');
      final totalUsers = (usersData as List).length;

      // Count total doctors (verified)
      final doctorsData = await _client
          .from('doctors')
          .select('id')
          .eq('is_verified', true);
      final totalDoctors = (doctorsData as List).length;

      // Count pending doctors
      final pendingData = await _client
          .from('doctors')
          .select('id')
          .eq('is_verified', false);
      final pendingDoctors = (pendingData as List).length;

      // Count total appointments
      final appointmentsData = await _client
          .from('appointments')
          .select('id');
      final totalAppointments = (appointmentsData as List).length;

      // Count today's appointments
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final todayData = await _client
          .from('appointments')
          .select('id')
          .eq('booking_date', todayStr);
      final todayAppointments = (todayData as List).length;

      // Sum total revenue from successful payments
      final paymentsData = await _client
          .from('payments')
          .select('amount')
          .eq('status', 'success');
      double totalRevenue = 0;
      for (final p in paymentsData as List) {
        totalRevenue += (p['amount'] as num).toDouble();
      }

      return AdminStats(
        totalUsers: totalUsers,
        totalDoctors: totalDoctors,
        totalAppointments: totalAppointments,
        totalRevenue: totalRevenue,
        pendingDoctors: pendingDoctors,
        todayAppointments: todayAppointments,
      );
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Get weekly appointment stats (last 7 days)
  Future<List<DailyAppointmentStat>> getWeeklyAppointmentStats() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 6));
      final weekAgoStr = '${weekAgo.year}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}';

      final data = await _client
          .from('appointments')
          .select('booking_date')
          .gte('booking_date', weekAgoStr)
          .order('booking_date');

      // Group by date
      final Map<String, int> countByDate = {};
      for (final row in data as List) {
        final date = row['booking_date'] as String;
        countByDate[date] = (countByDate[date] ?? 0) + 1;
      }

      // Build list for last 7 days
      final dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
      final result = <DailyAppointmentStat>[];
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        result.add(DailyAppointmentStat(
          dayLabel: dayNames[day.weekday % 7],
          count: countByDate[dayStr] ?? 0,
        ));
      }

      return result;
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Get all users with optional role filter and search
  Future<List<UserModel>> getAllUsers({String? roleFilter, String? search}) async {
    try {
      var query = _client.from('users').select();

      if (roleFilter != null && roleFilter.isNotEmpty) {
        query = query.eq('role', roleFilter);
      }

      final data = await query.order('created_at', ascending: false);

      var users = (data as List).map((e) => UserModel.fromJson(e)).toList();

      // Client-side search
      if (search != null && search.isNotEmpty) {
        final s = search.toLowerCase();
        users = users.where((u) =>
          u.fullName.toLowerCase().contains(s) ||
          u.email.toLowerCase().contains(s) ||
          (u.phone?.toLowerCase().contains(s) ?? false)
        ).toList();
      }

      return users;
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Toggle user active status
  Future<void> toggleUserActive(String userId, bool isActive) async {
    try {
      await _client
          .from('users')
          .update({'is_active': isActive})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await _client.from('users').delete().eq('id', userId);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Update user profile (admin edit)
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _client
          .from('users')
          .update(updates)
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Update user auth (email/password) via Edge Function
  /// Requires deploying 'admin-update-user' Edge Function with service_role key
  Future<void> updateUserAuth({
    required String userId,
    String? email,
    String? password,
  }) async {
    try {
      final body = <String, dynamic>{'user_id': userId};
      if (email != null) body['email'] = email;
      if (password != null) body['password'] = password;

      final response = await _client.functions.invoke(
        'admin-update-user',
        body: body,
      );

      final data = response.data;
      if (data is Map && data['error'] != null) {
        throw ServerFailure(data['error'].toString());
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Không thể cập nhật auth: $e');
    }
  }

  /// Get pending doctors (is_verified = false) with user info
  Future<List<DoctorModel>> getPendingDoctors() async {
    try {
      final data = await _client
          .from('doctors')
          .select('*, users(full_name, avatar_url, email, phone, created_at), specialities(name, name_vi, icon)')
          .eq('is_verified', false)
          .order('created_at', ascending: false);

      return (data as List).map((e) => DoctorModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Get approved doctors (is_verified = true) with user info
  Future<List<DoctorModel>> getApprovedDoctors() async {
    try {
      final data = await _client
          .from('doctors')
          .select('*, users(full_name, avatar_url, email, phone), specialities(name, name_vi, icon)')
          .eq('is_verified', true)
          .order('created_at', ascending: false);

      return (data as List).map((e) => DoctorModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Approve a doctor: set is_verified = true + set user is_active = true
  Future<void> approveDoctor(String doctorId) async {
    try {
      await _client
          .from('doctors')
          .update({'is_verified': true})
          .eq('id', doctorId);

      await _client
          .from('users')
          .update({'is_active': true})
          .eq('id', doctorId);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Reject a doctor: delete doctor record + keep user but is_active = false
  Future<void> rejectDoctor(String doctorId) async {
    try {
      await _client.from('doctors').delete().eq('id', doctorId);
      await _client
          .from('users')
          .update({'is_active': false})
          .eq('id', doctorId);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}

// ==================== RIVERPOD PROVIDERS ====================

/// Admin stats provider
final adminStatsProvider = FutureProvider<AdminStats>((ref) {
  return ref.watch(adminRepositoryProvider).getAdminStats();
});

/// Weekly appointment stats provider
final weeklyStatsProvider = FutureProvider<List<DailyAppointmentStat>>((ref) {
  return ref.watch(adminRepositoryProvider).getWeeklyAppointmentStats();
});

/// All users provider with filters
final adminUsersProvider = FutureProvider.family<List<UserModel>, ({String? role, String? search})>((ref, params) {
  return ref.watch(adminRepositoryProvider).getAllUsers(
    roleFilter: params.role,
    search: params.search,
  );
});

/// Pending doctors provider
final pendingDoctorsProvider = FutureProvider<List<DoctorModel>>((ref) {
  return ref.watch(adminRepositoryProvider).getPendingDoctors();
});

/// Approved doctors provider
final approvedDoctorsProvider = FutureProvider<List<DoctorModel>>((ref) {
  return ref.watch(adminRepositoryProvider).getApprovedDoctors();
});
