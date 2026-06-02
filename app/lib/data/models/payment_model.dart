import 'package:equatable/equatable.dart';

enum PaymentMethod { payos, cash }
enum PaymentStatus { pending, success, failed, refunded }

class PaymentModel extends Equatable {
  final String id;
  final String appointmentId;
  final String patientId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final String? idempotencyKey;
  final String? payosOrderCode;
  final Map<String, dynamic>? gatewayResponse;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.amount,
    required this.method,
    this.status = PaymentStatus.pending,
    this.transactionId,
    this.idempotencyKey,
    this.payosOrderCode,
    this.gatewayResponse,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      appointmentId: json['appointment_id'] as String,
      patientId: json['patient_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: _parseMethod(json['method'] as String),
      status: _parseStatus(json['status'] as String?),
      transactionId: json['transaction_id'] as String?,
      idempotencyKey: json['idempotency_key'] as String?,
      payosOrderCode: json['payos_order_code'] as String?,
      gatewayResponse: json['gateway_response'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'appointment_id': appointmentId,
    'patient_id': patientId,
    'amount': amount,
    'method': method.name,
    'status': status.name,
    'idempotency_key': idempotencyKey,
    'payos_order_code': payosOrderCode,
  };

  static PaymentMethod _parseMethod(String s) => switch (s) {
    'payos' => PaymentMethod.payos,
    _ => PaymentMethod.cash,
  };

  static PaymentStatus _parseStatus(String? s) => switch (s) {
    'success' => PaymentStatus.success,
    'failed' => PaymentStatus.failed,
    'refunded' => PaymentStatus.refunded,
    _ => PaymentStatus.pending,
  };

  String get displayAmount => '${amount.toStringAsFixed(0)}đ';
  bool get isSuccess => status == PaymentStatus.success;
  bool get isPending => status == PaymentStatus.pending;

  String get methodDisplayName => switch (method) {
    PaymentMethod.payos => 'PayOS',
    PaymentMethod.cash => 'Tiền mặt',
  };

  @override
  List<Object?> get props => [id, appointmentId, status];
}
