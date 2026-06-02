# ⚠️ XỬ LÝ LỖI, EDGE CASES, BẢO MẬT & MÔI TRƯỜNG

## 1. Error Handling Architecture

### 1.1 Failure Model (Result Pattern)

```dart
// Tất cả repository methods trả về Either<Failure, T>
sealed class Failure {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Không có kết nối mạng']) : super(message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(String message, {this.statusCode}) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure(String message, {String? code}) : super(message, code: code);
}

class PaymentFailure extends Failure {
  final String? transactionId;
  const PaymentFailure(String message, {this.transactionId}) : super(message);
}

class VideoCallFailure extends Failure {
  const VideoCallFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;
  const ValidationFailure(String message, {this.fieldErrors = const {}}) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Lỗi cache local']) : super(message);
}
```

### 1.2 Global Error Handler

```dart
// Đăng ký trong main.dart
void main() {
  // Bắt tất cả lỗi Flutter framework
  FlutterError.onError = (details) {
    ErrorReporter.reportFlutterError(details);
  };

  // Bắt tất cả lỗi async không được handle
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorReporter.reportError(error, stack);
    return true;
  };

  runApp(
    ProviderScope(
      observers: [ErrorObserver()], // Riverpod error observer
      child: const DoctorBookingApp(),
    ),
  );
}
```

### 1.3 Retry Strategy

```dart
class RetryConfig {
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(seconds: 1);
  static const double backoffMultiplier = 2.0;

  /// Exponential backoff retry
  static Future<T> withRetry<T>(
    Future<T> Function() action, {
    int maxAttempts = maxRetries,
    bool Function(Exception)? retryIf,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        attempt++;
        return await action();
      } on Exception catch (e) {
        if (attempt >= maxAttempts || (retryIf != null && !retryIf(e))) {
          rethrow;
        }
        await Future.delayed(delay);
        delay *= backoffMultiplier;
      }
    }
  }
}
```

---

## 2. Edge Cases Theo Module

### 2.1 Đặt Lịch (Booking)

| Edge Case | Xử lý |
|---|---|
| **Mất mạng giữa chừng khi đặt lịch** | Lưu draft local → retry khi có mạng → hiển thị trạng thái "Đang xử lý" |
| **2 bệnh nhân đặt cùng slot** | Optimistic locking: check lại slot trước khi INSERT, DB constraint UNIQUE(doctor_id, start_time, status != 'cancelled') |
| **Bác sĩ hủy lịch sát giờ** | Notification ngay lập tức + tự động hoàn tiền + gợi ý bác sĩ thay thế |
| **Bệnh nhân đặt quá nhiều lịch** | Giới hạn max 5 active appointments/patient, cảnh báo khi gần limit |
| **Slot hết hạn trong lúc chọn** | Real-time check: khi user mở booking → subscribe slot changes → auto-disable nếu bị đặt |
| **Timezone khác nhau** | Tất cả thời gian lưu TIMESTAMPTZ (UTC), hiển thị theo timezone thiết bị |

```dart
// Xử lý race condition khi đặt lịch
Future<Result<Appointment>> bookAppointment(BookingRequest request) async {
  try {
    // 1. Kiểm tra kết nối
    if (!await connectivityService.hasConnection) {
      return Result.failure(NetworkFailure('Vui lòng kiểm tra kết nối mạng'));
    }

    // 2. Kiểm tra slot còn trống (server-side)
    final isAvailable = await _checkSlotAvailability(
      request.doctorId, request.startTime, request.endTime,
    );
    if (!isAvailable) {
      return Result.failure(ValidationFailure('Slot này đã được đặt, vui lòng chọn slot khác'));
    }

    // 3. Tạo appointment (DB constraint sẽ bắt duplicate)
    final appointment = await supabase.from('appointments').insert({...}).select().single();
    return Result.success(Appointment.fromJson(appointment));

  } on PostgrestException catch (e) {
    if (e.code == '23505') { // Unique constraint violation
      return Result.failure(ValidationFailure('Slot vừa bị đặt, vui lòng chọn lại'));
    }
    return Result.failure(ServerFailure(e.message));
  }
}
```

### 2.2 Thanh Toán (Payment)

| Edge Case | Xử lý |
|---|---|
| **Thanh toán thất bại** | Hiển thị lỗi cụ thể + nút "Thử lại" + giữ appointment ở trạng thái `pending` 15 phút |
| **Thanh toán thành công nhưng callback thất bại** | Webhook retry 3 lần + cron job kiểm tra trạng thái từ payment gateway mỗi 5 phút |
| **User thoát app giữa chừng thanh toán** | Khi mở lại app → check pending payments → hiển thị dialog tiếp tục/hủy |
| **Hoàn tiền khi hủy lịch** | Hủy trước 24h: hoàn 100%, trước 6h: hoàn 50%, dưới 6h: không hoàn |
| **Timeout payment gateway** | Timeout 60s → hiển thị "Đang xử lý, vui lòng chờ" → polling status |
| **Double payment** | Idempotency key (UUID) cho mỗi transaction → gateway từ chối duplicate |

```dart
// Payment flow with edge case handling
class PaymentService {
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    final idempotencyKey = const Uuid().v4();

    try {
      // 1. Tạo payment record trước (status: pending)
      final payment = await _createPendingPayment(request, idempotencyKey);

      // 2. Redirect to payment gateway
      final gatewayResult = await _redirectToGateway(
        request.method, // momo | vnpay | zalopay
        payment.id,
        request.amount,
        idempotencyKey,
      );

      // 3. Handle gateway response
      return switch (gatewayResult.status) {
        'success' => _handleSuccess(payment.id, gatewayResult),
        'failed'  => _handleFailure(payment.id, gatewayResult),
        'pending' => _startPolling(payment.id), // Poll every 5s, max 12 times
        _         => PaymentResult.unknown(),
      };

    } on TimeoutException {
      return PaymentResult.timeout(message: 'Thanh toán đang xử lý, vui lòng chờ...');
    }
  }
}
```

### 2.3 Video Call (Telemedicine)

| Edge Case | Xử lý |
|---|---|
| **Mất kết nối giữa cuộc gọi** | Auto-reconnect 3 lần (mỗi lần cách 2s) → hiển thị "Đang kết nối lại..." → nếu fail: "Cuộc gọi bị gián đoạn" |
| **Camera/Mic bị từ chối quyền** | Hiển thị hướng dẫn bật quyền trong Settings → deep link tới app Settings |
| **Thiết bị không hỗ trợ camera** | Fallback sang voice-only call → thông báo cho đối phương |
| **Bác sĩ chưa vào phòng** | Waiting room với countdown 10 phút → auto-cancel nếu bác sĩ không xuất hiện |
| **Cuộc gọi kéo dài quá lâu** | Cảnh báo ở phút thứ 25 (nếu slot 30 phút) → auto-end ở phút 35 |
| **App bị kill giữa cuộc gọi** | Khi mở lại: check active session → rejoin nếu còn active |

### 2.4 Chat

| Edge Case | Xử lý |
|---|---|
| **Gửi tin nhắn khi offline** | Queue locally → auto-send khi có mạng → icon "đang gửi" |
| **File đính kèm quá lớn** | Giới hạn 10MB/file → compress ảnh tự động → hiển thị lỗi nếu vượt |
| **Spam messages** | Rate limit: max 30 tin/phút → cooldown 60s nếu vượt |
| **Conversation đã đóng** | Hiển thị "Cuộc trò chuyện đã kết thúc" → chỉ cho phép đọc |

---

## 3. Bảo Mật & Compliance

### 3.1 Xử Lý Dữ Liệu Y Tế Nhạy Cảm (PDPA Việt Nam)

#### Nguyên tắc chung
1. **Thu thập tối thiểu** — Chỉ thu thập dữ liệu cần thiết cho chức năng
2. **Đồng ý rõ ràng** — User phải đồng ý trước khi thu thập dữ liệu y tế
3. **Quyền truy cập** — User có quyền xem, sửa, xóa dữ liệu cá nhân
4. **Mã hóa** — Dữ liệu y tế phải được mã hóa khi lưu trữ và truyền tải

#### Phân loại dữ liệu

| Mức độ | Loại dữ liệu | Xử lý |
|---|---|---|
| 🔴 **Nhạy cảm cao** | Chẩn đoán, đơn thuốc, kết quả xét nghiệm, bệnh án | Mã hóa AES-256, RLS strict, audit log |
| 🟡 **Nhạy cảm** | Tên, email, số điện thoại, ngày sinh, nhóm máu | RLS, không log nội dung |
| 🟢 **Công khai** | Tên bác sĩ, chuyên khoa, phí tư vấn, rating | Readable by all authenticated |

#### Consent Management
```dart
// Hiển thị consent dialog trước khi thu thập dữ liệu y tế
class ConsentService {
  Future<bool> requestMedicalDataConsent() async {
    final consent = await showDialog<bool>(
      // Dialog giải thích rõ: thu thập gì, mục đích gì, lưu ở đâu, ai xem được
    );
    if (consent == true) {
      await _saveConsentRecord(userId, 'medical_data', DateTime.now());
    }
    return consent ?? false;
  }
}
```

### 3.2 Authentication & Session Management

```dart
class AuthConfig {
  // Token refresh
  static const Duration accessTokenLifetime = Duration(hours: 1);
  static const Duration refreshTokenLifetime = Duration(days: 30);
  static const Duration sessionTimeout = Duration(minutes: 30); // Inactive timeout

  // Supabase auto-refresh token khi còn < 60s
  // Custom: check session validity trước mỗi API call nhạy cảm
}

class SessionManager {
  Timer? _inactivityTimer;

  void startInactivityMonitor() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(AuthConfig.sessionTimeout, () {
      // Lock app → yêu cầu re-authenticate
      _lockApp();
    });
  }

  void onUserActivity() {
    // Reset timer mỗi khi user tương tác
    startInactivityMonitor();
  }

  Future<void> refreshTokenIfNeeded() async {
    final session = supabase.auth.currentSession;
    if (session == null) {
      throw AuthFailure('Phiên đăng nhập hết hạn');
    }

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
    if (expiresAt.difference(DateTime.now()).inMinutes < 5) {
      await supabase.auth.refreshSession();
    }
  }
}
```

### 3.3 Rate Limiting

```sql
-- Supabase Edge Function: rate limiting middleware
-- Giới hạn API calls theo user
CREATE TABLE rate_limits (
    user_id UUID NOT NULL REFERENCES users(id),
    endpoint TEXT NOT NULL,
    request_count INTEGER DEFAULT 0,
    window_start TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, endpoint)
);

-- Limits configuration
-- booking/create:     5 requests / 10 minutes
-- payment/process:    3 requests / 5 minutes
-- chat/send:          30 requests / 1 minute
-- auth/login:         5 requests / 15 minutes (brute-force protection)
-- video/create:       3 requests / 10 minutes
```

```dart
// Client-side rate limiting (phòng tránh spam UI)
class RateLimiter {
  final Map<String, List<DateTime>> _requests = {};

  bool canMakeRequest(String action, {int maxRequests = 5, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    _requests[action] = (_requests[action] ?? [])
      ..removeWhere((t) => now.difference(t) > window)
      ..add(now);
    return _requests[action]!.length <= maxRequests;
  }
}
```

### 3.4 Bảo Mật Khác

| Mục | Implementation |
|---|---|
| **HTTPS only** | Supabase mặc định HTTPS, app chặn HTTP requests |
| **Certificate pinning** | Cấu hình cho production builds |
| **Secure storage** | `flutter_secure_storage` cho tokens, KHÔNG dùng SharedPreferences |
| **Input sanitization** | Server-side: PostgreSQL parameterized queries (Supabase auto), Client-side: form validators |
| **File upload validation** | Chỉ cho phép: jpg, png, pdf. Max size: 10MB. Scan malware (Supabase Storage hooks) |
| **API Key protection** | Anon key trong app (OK), Service role key chỉ trong Edge Functions |
| **Audit logging** | Log tất cả thao tác nhạy cảm: login, đặt lịch, xem hồ sơ, thanh toán |

---

## 4. Cấu Hình Môi Trường (Environments)

### 4.1 Ba Môi Trường

| Môi trường | Mục đích | Supabase Project |
|---|---|---|
| **Development** | Phát triển local, test nhanh | `doctor-booking-dev` |
| **Staging** | Test trước khi release, UAT | `doctor-booking-staging` |
| **Production** | Sản phẩm thật, dữ liệu thật | `doctor-booking-prod` |

### 4.2 Environment Configuration

```dart
// lib/config/env.dart
enum Environment { dev, staging, prod }

class EnvConfig {
  final Environment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String agoraAppId;
  final String momoPartnerCode;
  final String vnpayTmnCode;
  final String zalopayAppId;
  final bool enableLogging;
  final bool enableCrashlytics;

  const EnvConfig._({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.agoraAppId,
    required this.momoPartnerCode,
    required this.vnpayTmnCode,
    required this.zalopayAppId,
    this.enableLogging = false,
    this.enableCrashlytics = false,
  });

  static const dev = EnvConfig._(
    environment: Environment.dev,
    supabaseUrl: 'https://xxx-dev.supabase.co',
    supabaseAnonKey: 'dev-anon-key',
    agoraAppId: 'agora-dev-app-id',
    momoPartnerCode: 'MOMO_TEST',
    vnpayTmnCode: 'VNPAY_SANDBOX',
    zalopayAppId: 'ZALOPAY_SANDBOX',
    enableLogging: true,
    enableCrashlytics: false,
  );

  static const staging = EnvConfig._(
    environment: Environment.staging,
    supabaseUrl: 'https://xxx-staging.supabase.co',
    supabaseAnonKey: 'staging-anon-key',
    agoraAppId: 'agora-staging-app-id',
    momoPartnerCode: 'MOMO_TEST',
    vnpayTmnCode: 'VNPAY_SANDBOX',
    zalopayAppId: 'ZALOPAY_SANDBOX',
    enableLogging: true,
    enableCrashlytics: true,
  );

  static const prod = EnvConfig._(
    environment: Environment.prod,
    supabaseUrl: 'https://xxx-prod.supabase.co',
    supabaseAnonKey: 'prod-anon-key',
    agoraAppId: 'agora-prod-app-id',
    momoPartnerCode: 'MOMO_REAL_PARTNER',
    vnpayTmnCode: 'VNPAY_REAL_TMN',
    zalopayAppId: 'ZALOPAY_REAL_APP',
    enableLogging: false,
    enableCrashlytics: true,
  );
}

// Sử dụng trong main.dart
void main() async {
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  final config = switch (env) {
    'prod'    => EnvConfig.prod,
    'staging' => EnvConfig.staging,
    _         => EnvConfig.dev,
  };
  // ...
}
```

### 4.3 Chạy Theo Môi Trường

```powershell
# Development (mặc định)
flutter run

# Staging
flutter run --dart-define=ENV=staging

# Production
flutter run --release --dart-define=ENV=prod

# Build APK production
flutter build apk --release --dart-define=ENV=prod
```

### 4.4 Payment Gateway Sandbox vs Production

| Gateway | Sandbox | Production |
|---|---|---|
| **MoMo** | `https://test-payment.momo.vn` | `https://payment.momo.vn` |
| **VNPay** | `https://sandbox.vnpayment.vn` | `https://pay.vnpay.vn` |
| **ZaloPay** | `https://sb-openapi.zalopay.vn` | `https://openapi.zalopay.vn` |

> ⚠️ **QUAN TRỌNG**: KHÔNG BAO GIỜ dùng production payment keys trong dev/staging. Tài khoản test riêng biệt cho mỗi gateway.

---

## 5. Connectivity & Offline Handling

### 5.1 Network Monitor

```dart
class ConnectivityService {
  final _connectivity = Connectivity();

  Stream<bool> get onConnectivityChanged =>
    _connectivity.onConnectivityChanged.map((result) =>
      result != ConnectivityResult.none
    );

  Future<bool> get hasConnection async {
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) return false;
    // Double-check with actual HTTP request
    try {
      final response = await http.get(Uri.parse('https://your-supabase.co/rest/v1/')).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
```

### 5.2 Offline Queue

> ⚠️ **Lưu ý bảo mật**: Queue có thể chứa booking data (doctor ID, thời gian, ghi chú bệnh nhân)
> nên được coi là dữ liệu nhạy cảm. Dùng `FlutterSecureStorage` thay vì `SharedPreferences`.

```dart
// Hành động cần thực hiện khi offline → queue lại
class OfflineQueue {
  static const _queueKey = 'offline_queue';
  final _storage = const FlutterSecureStorage();

  Future<void> enqueue(OfflineAction action) async {
    final existing = await _storage.read(key: _queueKey);
    final queue = existing != null
        ? List<String>.from(jsonDecode(existing))
        : <String>[];
    queue.add(jsonEncode(action.toJson()));
    await _storage.write(key: _queueKey, value: jsonEncode(queue));
  }

  Future<void> processQueue() async {
    final existing = await _storage.read(key: _queueKey);
    if (existing == null) return;

    final queue = List<String>.from(jsonDecode(existing));
    final remaining = <String>[];

    for (final item in queue) {
      try {
        final action = OfflineAction.fromJson(jsonDecode(item));
        await action.execute();
        // Thành công → không thêm vào remaining
      } catch (e) {
        remaining.add(item); // Giữ lại để retry sau
      }
    }

    if (remaining.isEmpty) {
      await _storage.delete(key: _queueKey);
    } else {
      await _storage.write(key: _queueKey, value: jsonEncode(remaining));
    }
  }
}
```

---

## 6. Error UI Components

### 6.1 User-Friendly Error Messages

```dart
// Mapping technical errors → user-friendly messages
class ErrorMessages {
  static const Map<String, String> vi = {
    'network_error': 'Không có kết nối mạng. Vui lòng kiểm tra Wi-Fi hoặc dữ liệu di động.',
    'server_error': 'Hệ thống đang bảo trì. Vui lòng thử lại sau ít phút.',
    'auth_expired': 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
    'slot_taken': 'Rất tiếc, slot này vừa được đặt. Vui lòng chọn slot khác.',
    'payment_failed': 'Thanh toán không thành công. Vui lòng thử lại hoặc đổi phương thức.',
    'payment_timeout': 'Thanh toán đang xử lý. Vui lòng chờ và kiểm tra lại sau.',
    'video_permission': 'Cần quyền truy cập camera và microphone để gọi video.',
    'video_disconnected': 'Cuộc gọi bị gián đoạn. Đang kết nối lại...',
    'file_too_large': 'Tệp quá lớn. Vui lòng chọn tệp nhỏ hơn 10MB.',
    'rate_limited': 'Bạn đang thao tác quá nhanh. Vui lòng chờ một chút.',
  };

  static const Map<String, String> en = {
    'network_error': 'No internet connection. Please check your Wi-Fi or mobile data.',
    'server_error': 'System is under maintenance. Please try again later.',
    // ...
  };
}
```

### 6.2 Error Widgets

```dart
// Retry widget cho tất cả screens
class ErrorRetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  // Hiển thị: Icon lỗi + message + nút "Thử lại"
}

// Offline banner
class OfflineBanner extends StatelessWidget {
  // Hiển thị banner "Không có kết nối mạng" ở top của app
  // Auto-hide khi có mạng trở lại
}

// Payment pending dialog
class PaymentPendingDialog extends StatelessWidget {
  // Hiển thị khi user quay lại app sau khi thanh toán
  // "Đang kiểm tra trạng thái thanh toán..."
}
```
