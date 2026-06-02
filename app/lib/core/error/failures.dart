/// Base failure class for all errors in the app
sealed class Failure {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure($code): $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Không có kết nối mạng']) : super(message, code: 'NETWORK');
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(String message, {this.statusCode}) : super(message, code: 'SERVER');
}

class AuthFailure extends Failure {
  const AuthFailure(String message, {String? code}) : super(message, code: code ?? 'AUTH');
}

class PaymentFailure extends Failure {
  final String? transactionId;
  const PaymentFailure(String message, {this.transactionId}) : super(message, code: 'PAYMENT');
}

class VideoCallFailure extends Failure {
  const VideoCallFailure(String message) : super(message, code: 'VIDEO');
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;
  const ValidationFailure(String message, {this.fieldErrors = const {}}) : super(message, code: 'VALIDATION');
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Lỗi cache local']) : super(message, code: 'CACHE');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Không tìm thấy dữ liệu']) : super(message, code: 'NOT_FOUND');
}
