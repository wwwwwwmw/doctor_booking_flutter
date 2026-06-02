import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/core/di/di_providers.dart';
import 'package:doctor_booking_app/core/error/failures.dart';
import 'package:doctor_booking_app/data/models/user_model.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Login with email & password
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const AuthFailure('Đăng nhập thất bại');
      }
      return await getUserProfile(response.user!.id);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  /// Register new account
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': role},
      );
      if (response.user == null) {
        throw const AuthFailure('Đăng ký thất bại');
      }

      // Create profile
      final userData = {
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'role': role,
        'is_active': true,
      };
      await _client.from('users').insert(userData);

      // If doctor, create doctor profile
      if (role == 'doctor') {
        await _client.from('doctors').insert({'id': response.user!.id});
      }

      return UserModel.fromJson({...userData, 'created_at': DateTime.now().toIso8601String()});
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Get user profile from DB
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final data = await _client.from('users').select().eq('id', userId).single();
      return UserModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      final data = await _client
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      return UserModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get current session
  Session? get currentSession => _client.auth.currentSession;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;
}
