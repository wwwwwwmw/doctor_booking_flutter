import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:doctor_booking_app/core/di/di_providers.dart';
import 'package:doctor_booking_app/core/error/failures.dart';
import 'package:doctor_booking_app/data/models/payment_model.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(supabaseClientProvider));
});

class PaymentRepository {
  final SupabaseClient _client;
  final _uuid = const Uuid();

  PaymentRepository(this._client);

  /// Create a payment record with idempotency key
  Future<PaymentModel> createPayment({
    required String appointmentId,
    required String patientId,
    required double amount,
    required PaymentMethod method,
  }) async {
    final idempotencyKey = _uuid.v4();

    try {
      final data = await _client.from('payments').insert({
        'appointment_id': appointmentId,
        'patient_id': patientId,
        'amount': amount,
        'method': method.name,
        'status': 'pending',
        'idempotency_key': idempotencyKey,
      }).select().single();

      return PaymentModel.fromJson(data);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Update payment status (called by webhook/callback)
  Future<void> updatePaymentStatus({
    required String paymentId,
    required PaymentStatus status,
    String? transactionId,
    Map<String, dynamic>? gatewayResponse,
  }) async {
    try {
      await _client.from('payments').update({
        'status': status.name,
        'transaction_id': transactionId,
        'gateway_response': gatewayResponse,
      }).eq('id', paymentId);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Get payment for an appointment
  Future<PaymentModel?> getPaymentByAppointment(String appointmentId) async {
    try {
      final data = await _client
          .from('payments')
          .select()
          .eq('appointment_id', appointmentId)
          .order('created_at', ascending: false)
          .maybeSingle();

      return data != null ? PaymentModel.fromJson(data) : null;
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Get payment history for a patient
  Future<List<PaymentModel>> getPaymentHistory(String patientId) async {
    try {
      final data = await _client
          .from('payments')
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);

      return (data as List).map((e) => PaymentModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  /// Initiate PayOS payment (calls Supabase Edge Function)
  /// PayOS supports: QR code, bank transfer, e-wallets (MoMo, ZaloPay, etc.)
  Future<String> initiatePayosPayment({
    required String paymentId,
    required double amount,
    required String orderInfo,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    try {
      final orderCode = DateTime.now().millisecondsSinceEpoch;

      final response = await _client.functions.invoke(
        'create-payos-payment',
        body: {
          'payment_id': paymentId,
          'order_code': orderCode,
          'amount': amount.toInt(),
          'description': orderInfo,
          'return_url': returnUrl,
          'cancel_url': cancelUrl,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final checkoutUrl = data['checkoutUrl'] as String?;

      if (checkoutUrl == null) {
        throw const PaymentFailure('Không tạo được link thanh toán PayOS');
      }

      // Save order code
      await _client.from('payments').update({
        'payos_order_code': orderCode.toString(),
      }).eq('id', paymentId);

      return checkoutUrl;
    } catch (e) {
      throw PaymentFailure('Lỗi PayOS: $e');
    }
  }

  /// Check PayOS payment status
  Future<PaymentStatus> checkPayosPaymentStatus(String orderCode) async {
    try {
      final response = await _client.functions.invoke(
        'check-payos-status',
        body: {'order_code': orderCode},
      );

      final data = response.data as Map<String, dynamic>;
      final status = data['status'] as String?;

      return switch (status) {
        'PAID' => PaymentStatus.success,
        'CANCELLED' => PaymentStatus.failed,
        _ => PaymentStatus.pending,
      };
    } catch (e) {
      throw PaymentFailure('Không kiểm tra được trạng thái: $e');
    }
  }
}
