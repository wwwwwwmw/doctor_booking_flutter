# 🧪 CHIẾN LƯỢC TESTING - Goal-Driven Development

## 1. Triết Lý: Đặt Mục Tiêu → Xây → Test → Sửa → Lặp Lại

```
┌─────────────────────────────────────────────────────────────────┐
│                    VÒNG LẶP PHÁT TRIỂN                         │
│                                                                 │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌─────────┐ │
│   │ 1. DEFINE │───▶│ 2. BUILD │───▶│ 3. TEST  │───▶│ 4. FIX  │ │
│   │   GOAL    │    │ FEATURE  │    │ (auto)   │    │  BUGS   │ │
│   └──────────┘    └──────────┘    └────┬─────┘    └────┬────┘ │
│        ▲                               │               │       │
│        │          ┌──────────┐         │               │       │
│        └──────────│ 5. PASS? │◀────────┘───────────────┘       │
│                   └────┬─────┘                                  │
│                   YES  │                                        │
│                        ▼                                        │
│                 ┌──────────────┐                                │
│                 │ 6. NEXT GOAL │                                │
│                 └──────────────┘                                │
└─────────────────────────────────────────────────────────────────┘
```

### Quy trình cho MỖI chức năng:

1. **DEFINE** — Viết test cases (acceptance criteria) TRƯỚC khi code
2. **BUILD** — Implement tính năng
3. **TEST** — Chạy `flutter test` → phải PASS hết
4. **FIX** — Nếu FAIL → sửa code, KHÔNG sửa test
5. **PASS** — Tất cả tests PASS → commit → chuyển sang goal tiếp theo

---

## 2. Các Tầng Testing

```
┌──────────────────────────────────────────────┐
│           Integration Tests (E2E)            │  ← Ít nhất, chậm nhất
│        Kiểm tra toàn bộ user flow            │
├──────────────────────────────────────────────┤
│            Widget Tests (UI)                 │  ← Trung bình
│      Kiểm tra từng screen/widget             │
├──────────────────────────────────────────────┤
│          Unit Tests (Logic)                  │  ← Nhiều nhất, nhanh nhất
│  Models, Repositories, UseCases, Providers   │
└──────────────────────────────────────────────┘
```

| Tầng | Tỷ lệ | Tốc độ | Mục đích |
|---|---|---|---|
| Unit Tests | ~70% | <1s/test | Business logic, data transform, validation |
| Widget Tests | ~20% | ~2-5s/test | UI render đúng, user interaction |
| Integration Tests | ~10% | ~30-60s/test | Full user flow end-to-end |

---

## 3. Cấu Trúc Thư Mục Test

```
test/
├── unit/                              # Unit Tests
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model_test.dart
│   │   │   ├── doctor_model_test.dart
│   │   │   ├── appointment_model_test.dart
│   │   │   ├── payment_model_test.dart
│   │   │   └── chat_message_model_test.dart
│   │   ├── repositories/
│   │   │   ├── auth_repository_test.dart
│   │   │   ├── appointment_repository_test.dart
│   │   │   ├── payment_repository_test.dart
│   │   │   └── chat_repository_test.dart
│   │   └── datasources/
│   │       └── ...
│   │
│   ├── domain/
│   │   └── usecases/
│   │       ├── auth/
│   │       │   ├── login_usecase_test.dart
│   │       │   └── register_usecase_test.dart
│   │       ├── appointment/
│   │       │   ├── book_appointment_test.dart
│   │       │   ├── cancel_appointment_test.dart
│   │       │   └── get_appointments_test.dart
│   │       ├── payment/
│   │       │   └── process_payment_test.dart
│   │       └── doctor/
│   │           └── search_doctors_test.dart
│   │
│   └── core/
│       ├── utils/
│       │   ├── validators_test.dart
│       │   └── date_utils_test.dart
│       └── services/
│           ├── connectivity_test.dart
│           └── rate_limiter_test.dart
│
├── widget/                            # Widget Tests
│   ├── common/
│   │   ├── app_button_test.dart
│   │   ├── app_text_field_test.dart
│   │   └── error_retry_widget_test.dart
│   ├── patient/
│   │   ├── home/
│   │   │   └── patient_home_screen_test.dart
│   │   ├── booking/
│   │   │   └── book_appointment_screen_test.dart
│   │   ├── reviews/
│   │   │   └── write_review_screen_test.dart
│   │   └── payment/
│   │       └── payment_checkout_screen_test.dart
│   ├── doctor/
│   │   ├── home/
│   │   │   └── doctor_dashboard_test.dart
│   │   └── analytics/
│   │       └── analytics_dashboard_test.dart
│   ├── chat/
│   │   ├── chat_inbox_test.dart
│   │   └── chat_conversation_test.dart
│   └── telemedicine/
│       └── video_call_screen_test.dart
│
├── integration/                       # Integration Tests (E2E)
│   ├── auth_flow_test.dart
│   ├── booking_flow_test.dart
│   ├── payment_flow_test.dart
│   ├── chat_flow_test.dart
│   └── review_flow_test.dart
│
├── mocks/                             # Shared mocks
│   ├── mock_supabase.dart
│   ├── mock_auth_repository.dart
│   ├── mock_appointment_repository.dart
│   ├── mock_payment_service.dart
│   └── mock_connectivity.dart
│
├── fixtures/                          # Test data
│   ├── doctor_fixtures.dart
│   ├── appointment_fixtures.dart
│   ├── payment_fixtures.dart
│   └── json/
│       ├── doctor_response.json
│       ├── appointment_response.json
│       └── payment_response.json
│
└── helpers/                           # Test utilities
    ├── test_app.dart                  # Wrapper with providers
    ├── pump_app.dart                  # Widget test helper
    └── fake_supabase_client.dart
```

---

## 4. Goal-Driven Test Cases

### 🎯 Goal 1: Authentication

**Mục tiêu**: User có thể đăng ký, đăng nhập, đăng xuất thành công.

#### Unit Tests
```dart
// test/unit/domain/usecases/auth/login_usecase_test.dart
void main() {
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepo);
  });

  group('LoginUseCase', () {
    test('✅ should return User when login with valid credentials', () async {
      when(mockRepo.login('test@mail.com', 'pass123'))
          .thenAnswer((_) async => Right(testUser));

      final result = await loginUseCase.execute('test@mail.com', 'pass123');
      expect(result.isRight(), true);
    });

    test('❌ should return AuthFailure when credentials are invalid', () async {
      when(mockRepo.login('test@mail.com', 'wrong'))
          .thenAnswer((_) async => Left(AuthFailure('Invalid credentials')));

      final result = await loginUseCase.execute('test@mail.com', 'wrong');
      expect(result.isLeft(), true);
    });

    test('❌ should return NetworkFailure when offline', () async {
      when(mockRepo.login(any, any))
          .thenAnswer((_) async => Left(NetworkFailure()));

      final result = await loginUseCase.execute('test@mail.com', 'pass');
      expect(result.fold((l) => l, (r) => null), isA<NetworkFailure>());
    });

    test('✅ should validate email format before calling repo', () async {
      final result = await loginUseCase.execute('invalid-email', 'pass');
      expect(result.isLeft(), true);
      verifyNever(mockRepo.login(any, any)); // Không gọi repo nếu email sai
    });
  });
}
```

#### Widget Tests
```dart
// test/widget/common/login_screen_test.dart
void main() {
  group('LoginScreen', () {
    testWidgets('✅ should show email and password fields', (tester) async {
      await tester.pumpApp(const LoginScreen());
      expect(find.byKey(Key('email_field')), findsOneWidget);
      expect(find.byKey(Key('password_field')), findsOneWidget);
      expect(find.byKey(Key('login_button')), findsOneWidget);
    });

    testWidgets('❌ should show error when email is empty', (tester) async {
      await tester.pumpApp(const LoginScreen());
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pump();
      expect(find.text('Vui lòng nhập email'), findsOneWidget);
    });

    testWidgets('✅ should navigate to home on successful login', (tester) async {
      // Setup mock provider that returns success
      await tester.pumpApp(const LoginScreen(), overrides: [
        authProvider.overrideWith((_) => MockAuthNotifier(loggedIn: true)),
      ]);
      await tester.enterText(find.byKey(Key('email_field')), 'test@mail.com');
      await tester.enterText(find.byKey(Key('password_field')), 'pass123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();
      expect(find.byType(PatientHomeScreen), findsOneWidget);
    });
  });
}
```

---

### 🎯 Goal 2: Smart Booking

**Mục tiêu**: Bệnh nhân có thể xem real-time slots, chọn slot, đặt lịch thành công.

#### Unit Tests
```dart
// test/unit/domain/usecases/appointment/book_appointment_test.dart
void main() {
  group('BookAppointmentUseCase', () {
    test('✅ should create appointment with valid slot', () async {
      when(mockRepo.checkSlotAvailable(doctorId, startTime, endTime))
          .thenAnswer((_) async => true);
      when(mockRepo.createAppointment(any))
          .thenAnswer((_) async => Right(testAppointment));

      final result = await useCase.execute(bookingRequest);
      expect(result.isRight(), true);
    });

    test('❌ should fail when slot is already taken', () async {
      when(mockRepo.checkSlotAvailable(any, any, any))
          .thenAnswer((_) async => false);

      final result = await useCase.execute(bookingRequest);
      expect(result.fold((l) => l.message, (r) => ''), contains('slot'));
    });

    test('❌ should fail when patient has 5+ active appointments', () async {
      when(mockRepo.getActiveAppointmentCount(patientId))
          .thenAnswer((_) async => 5);

      final result = await useCase.execute(bookingRequest);
      expect(result.isLeft(), true);
    });

    test('❌ should fail when booking in the past', () async {
      final pastRequest = bookingRequest.copyWith(
        startTime: DateTime.now().subtract(Duration(hours: 1)),
      );
      final result = await useCase.execute(pastRequest);
      expect(result.isLeft(), true);
    });
  });
}
```

---

### 🎯 Goal 3: Payment

**Mục tiêu**: Thanh toán MoMo/VNPay/ZaloPay thành công, xử lý được thất bại và hoàn tiền.

```dart
// test/unit/data/repositories/payment_repository_test.dart
void main() {
  group('PaymentRepository', () {
    test('✅ should create pending payment record', () async {
      final result = await repo.createPayment(paymentRequest);
      expect(result.status, PaymentStatus.pending);
      expect(result.idempotencyKey, isNotNull);
    });

    test('✅ should update status to success on callback', () async {
      final result = await repo.handleCallback(successCallback);
      expect(result.status, PaymentStatus.success);
    });

    test('✅ should process refund for cancelled appointment (>24h)', () async {
      final appointment = testAppointment.copyWith(
        startTime: DateTime.now().add(Duration(hours: 25)),
      );
      final refund = await repo.processRefund(appointment.id);
      expect(refund.refundPercent, 100);
    });

    test('✅ should process 50% refund (6-24h before)', () async {
      final appointment = testAppointment.copyWith(
        startTime: DateTime.now().add(Duration(hours: 12)),
      );
      final refund = await repo.processRefund(appointment.id);
      expect(refund.refundPercent, 50);
    });

    test('❌ should reject refund (<6h before)', () async {
      final appointment = testAppointment.copyWith(
        startTime: DateTime.now().add(Duration(hours: 3)),
      );
      final result = await repo.processRefund(appointment.id);
      expect(result.isLeft(), true);
    });

    test('❌ should prevent duplicate payment (idempotency)', () async {
      await repo.createPayment(paymentRequest); // First
      final result = await repo.createPayment(paymentRequest); // Duplicate
      expect(result.isLeft(), true); // Should fail
    });
  });
}
```

---

### 🎯 Goal 4: Chat

```dart
// test/unit/data/repositories/chat_repository_test.dart
void main() {
  group('ChatRepository', () {
    test('✅ should create conversation for confirmed appointment', () async {
      final result = await repo.createConversation(confirmedAppointment.id);
      expect(result.isRight(), true);
    });

    test('❌ should not create conversation for pending appointment', () async {
      final result = await repo.createConversation(pendingAppointment.id);
      expect(result.isLeft(), true);
    });

    test('✅ should send text message', () async {
      final result = await repo.sendMessage(conversationId, 'Hello', MessageType.text);
      expect(result.isRight(), true);
    });

    test('❌ should reject message in closed conversation', () async {
      final result = await repo.sendMessage(closedConversationId, 'Hello', MessageType.text);
      expect(result.isLeft(), true);
    });

    test('❌ should reject file over 10MB', () async {
      final bigFile = MockFile(sizeInBytes: 11 * 1024 * 1024);
      final result = await repo.sendFile(conversationId, bigFile);
      expect(result.fold((l) => l.message, (r) => ''), contains('10MB'));
    });
  });
}
```

---

### 🎯 Goal 5: Video Call

```dart
// test/unit/data/repositories/video_call_repository_test.dart
void main() {
  group('VideoCallRepository', () {
    test('✅ should create session for video appointment', () async {
      final appointment = testAppointment.copyWith(consultationType: ConsultationType.video);
      final result = await repo.createSession(appointment.id);
      expect(result.channelName, isNotEmpty);
      expect(result.status, CallStatus.waiting);
    });

    test('❌ should reject session for in-person appointment', () async {
      final appointment = testAppointment.copyWith(consultationType: ConsultationType.inPerson);
      final result = await repo.createSession(appointment.id);
      expect(result.isLeft(), true);
    });

    test('✅ should allow join within 5 minutes before start', () async {
      final appointment = testAppointment.copyWith(
        startTime: DateTime.now().add(Duration(minutes: 3)),
      );
      final canJoin = await repo.canJoinCall(appointment);
      expect(canJoin, true);
    });

    test('❌ should not allow join 30+ minutes before start', () async {
      final appointment = testAppointment.copyWith(
        startTime: DateTime.now().add(Duration(minutes: 30)),
      );
      final canJoin = await repo.canJoinCall(appointment);
      expect(canJoin, false);
    });
  });
}
```

---

### 🎯 Goal 6: Rating & Review

```dart
void main() {
  group('ReviewRepository', () {
    test('✅ should create review for completed appointment', () async {
      final result = await repo.createReview(
        appointmentId: completedAppointment.id,
        rating: 5,
        comment: 'Bác sĩ rất tận tâm',
      );
      expect(result.isRight(), true);
    });

    test('❌ should reject review for non-completed appointment', () async {
      final result = await repo.createReview(
        appointmentId: pendingAppointment.id,
        rating: 5,
        comment: 'Test',
      );
      expect(result.isLeft(), true);
    });

    test('❌ should reject duplicate review', () async {
      await repo.createReview(appointmentId: id, rating: 5, comment: 'Good');
      final result = await repo.createReview(appointmentId: id, rating: 3, comment: 'Bad');
      expect(result.isLeft(), true); // Already reviewed
    });

    test('✅ should update doctor average rating after review', () async {
      await repo.createReview(appointmentId: id, rating: 4, comment: 'Good');
      final doctor = await doctorRepo.getById(doctorId);
      expect(doctor.ratingAvg, greaterThan(0));
    });

    test('✅ should allow edit within 24 hours', () async {
      // ... edit review test
    });

    test('❌ should reject edit after 24 hours', () async {
      // ... expired edit test
    });
  });
}
```

---

## 5. Lệnh Chạy Test

### 5.1 Chạy Tất Cả Tests

```powershell
# Tất cả unit + widget tests
flutter test

# Với coverage report
flutter test --coverage

# Xem coverage report (cần cài lcov)
# genhtml coverage/lcov.info -o coverage/html
# mở coverage/html/index.html
```

### 5.2 Chạy Theo Module

```powershell
# Chỉ unit tests
flutter test test/unit/

# Chỉ widget tests
flutter test test/widget/

# Chỉ test cho module cụ thể
flutter test test/unit/domain/usecases/auth/
flutter test test/unit/data/repositories/payment_repository_test.dart

# Integration tests (cần device/emulator)
flutter test integration_test/
```

### 5.3 Chạy Trong CI/CD

```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.2'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - name: Install coverage tools
        run: sudo apt-get update && sudo apt-get install -y lcov bc
      - name: Check coverage threshold
        run: |
          # Yêu cầu tối thiểu 80% coverage
          COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep 'lines' | awk '{print $2}' | sed 's/%//')
          echo "Current coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "❌ Coverage $COVERAGE% < 80% threshold"
            exit 1
          else
            echo "✅ Coverage $COVERAGE% >= 80% threshold"
          fi
```

---

## 6. Test Helpers & Mocks

### 6.1 Test App Wrapper

```dart
// test/helpers/test_app.dart
extension WidgetTesterX on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: [
          // Default mocks
          supabaseProvider.overrideWithValue(FakeSupabaseClient()),
          connectivityProvider.overrideWithValue(MockConnectivity(online: true)),
          ...overrides,
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
      ),
    );
    await pumpAndSettle();
  }
}
```

### 6.2 Fixtures

```dart
// test/fixtures/appointment_fixtures.dart
class AppointmentFixtures {
  static final now = DateTime(2026, 5, 10, 10, 0);

  static final pendingAppointment = Appointment(
    id: 'apt-001',
    patientId: 'pat-001',
    doctorId: 'doc-001',
    bookingDate: now,
    startTime: now,
    endTime: now.add(Duration(minutes: 30)),
    status: AppointmentStatus.pending,
    consultationType: ConsultationType.inPerson,
  );

  static final confirmedAppointment = pendingAppointment.copyWith(
    id: 'apt-002',
    status: AppointmentStatus.confirmed,
  );

  static final completedAppointment = pendingAppointment.copyWith(
    id: 'apt-003',
    status: AppointmentStatus.completed,
  );

  static final videoAppointment = pendingAppointment.copyWith(
    id: 'apt-004',
    consultationType: ConsultationType.video,
  );
}
```

---

## 7. Quy Tắc Viết Test

### DOs ✅
1. **Mỗi test chỉ kiểm tra 1 thứ** — 1 assertion chính per test
2. **Tên test mô tả rõ kết quả** — `should return error when slot is taken`
3. **Test cả happy path và error path** — ✅ success + ❌ failure
4. **Dùng fixtures/factories** cho test data — KHÔNG hardcode data trong test
5. **Mock dependencies** — test UseCase thì mock Repository, test Repository thì mock DataSource
6. **Chạy test TRƯỚC khi commit** — `flutter test` phải pass 100%

### DON'Ts ❌
1. **Không test implementation details** — test behavior, không test HOW
2. **Không test framework code** — không test Riverpod/AutoRoute bản thân
3. **Không có test phụ thuộc nhau** — mỗi test phải chạy độc lập
4. **Không sửa test để pass** — nếu test fail, sửa CODE không sửa TEST
5. **Không bỏ qua test** — KHÔNG dùng `skip: true` lâu dài

---

## 8. Checklist Test Theo Feature

Trước khi coi một feature là **DONE**, phải pass checklist sau:

### Per Feature Checklist
- [ ] Unit tests cho tất cả use cases (happy + error paths)
- [ ] Unit tests cho model serialization (fromJson/toJson)
- [ ] Widget tests cho screen chính
- [ ] Widget tests cho error states (loading, error, empty)
- [ ] Edge case tests (offline, timeout, invalid input)
- [ ] `flutter test` pass 100%
- [ ] `flutter analyze` không có errors
- [ ] Coverage > 80% cho module đó

### Lệnh kiểm tra nhanh trước commit
```powershell
# Chạy tất cả trong 1 lệnh
flutter analyze && flutter test
```

---

## 9. Test Coverage Targets

| Module | Target Coverage | Ghi chú |
|---|---|---|
| **Models (data)** | 95%+ | fromJson, toJson, copyWith, equality |
| **Repositories** | 90%+ | Tất cả CRUD + error handling |
| **Use Cases** | 90%+ | Business logic, validation |
| **Providers** | 80%+ | State transitions |
| **Widgets** | 70%+ | Render, interaction, error states |
| **Services** | 85%+ | Payment, Video, Chat, Notification |
| **Utils/Helpers** | 95%+ | Pure functions, validators |
| **Overall** | **≥ 80%** | **Minimum để merge vào main** |
