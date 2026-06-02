import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:doctor_booking_app/core/di/di_providers.dart';
import 'package:doctor_booking_app/core/error/failures.dart';
import 'package:doctor_booking_app/data/models/review_model.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(supabaseClientProvider));
});

class ReviewRepository {
  final SupabaseClient _client;

  ReviewRepository(this._client);

  /// Get reviews for a doctor
  Future<List<ReviewModel>> getDoctorReviews(String doctorId) async {
    try {
      final data = await _client
          .from('reviews')
          .select('*, users(full_name, avatar_url)')
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);

      return (data as List).map((e) => ReviewModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Submit a review
  Future<ReviewModel> submitReview(ReviewModel review) async {
    try {
      // Check if already reviewed
      if (review.appointmentId != null) {
        final existing = await _client
            .from('reviews')
            .select('id')
            .eq('appointment_id', review.appointmentId!)
            .maybeSingle();

        if (existing != null) {
          throw const ValidationFailure('Bạn đã đánh giá lịch hẹn này rồi');
        }
      }

      final data = await _client
          .from('reviews')
          .insert(review.toInsertJson())
          .select()
          .single();

      return ReviewModel.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const ValidationFailure('Bạn đã đánh giá lịch hẹn này rồi');
      }
      throw ServerFailure(e.message);
    }
  }

  /// Get average rating stats for a doctor
  Future<Map<String, dynamic>> getDoctorRatingStats(String doctorId) async {
    try {
      final data = await _client
          .from('reviews')
          .select('rating')
          .eq('doctor_id', doctorId);

      final reviews = data as List;
      if (reviews.isEmpty) {
        return {'average': 0.0, 'count': 0, 'distribution': <int, int>{}};
      }

      final ratings = reviews.map((e) => e['rating'] as int).toList();
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      final distribution = <int, int>{};
      for (int i = 1; i <= 5; i++) {
        distribution[i] = ratings.where((r) => r == i).length;
      }

      return {'average': avg, 'count': ratings.length, 'distribution': distribution};
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
