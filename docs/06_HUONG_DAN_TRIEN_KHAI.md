# 🚀 HƯỚNG DẪN TRIỂN KHAI & KHỞI TẠO DỰ ÁN MỚI

## 1. Yêu Cầu Hệ Thống

| Công cụ | Phiên bản hiện tại | Yêu cầu tối thiểu |
|---|---|---|
| **Flutter** | 3.41.2 (stable) | >= 3.22.0 |
| **Dart** | 3.11.0 | >= 3.4.0 |
| **Android Studio** | Latest | Latest |
| **VS Code** | Latest | Latest (khuyến nghị) |
| **Git** | Latest | Latest |

## 2. Thiết Lập Supabase

### 2.1 Tạo Project Supabase
1. Truy cập https://supabase.com → Sign Up / Login
2. Tạo New Project:
   - **Name**: `doctor-booking`
   - **Database Password**: (lưu lại password này)
   - **Region**: `Southeast Asia (Singapore)` ← gần VN nhất
3. Đợi project khởi tạo (~2 phút)

### 2.2 Lấy API Keys
Vào **Settings → API**:
- **Project URL**: `https://xxxxx.supabase.co`
- **Anon Key**: `eyJhbGciOiJIUzI1NiIs...` (public key, safe to expose)
- **Service Role Key**: `eyJhbGciOiJIUzI1NiIs...` (KHÔNG ĐƯỢC lộ key này)

### 2.3 Tạo Database Schema
1. Vào **SQL Editor** trong Supabase Dashboard
2. Copy toàn bộ SQL từ file `03_CO_SO_DU_LIEU.md` (phần SQL Schema)
3. Chạy từng block SQL theo thứ tự

### 2.4 Cấu Hình Authentication
1. Vào **Authentication → Providers**
2. Enable **Email** (đã mặc định)
3. Enable **Google**:
   - Tạo OAuth 2.0 credentials tại Google Cloud Console
   - Nhập Client ID + Client Secret
4. Cấu hình **Email Templates** (tùy chọn)
5. Bật **Confirm email** nếu muốn xác minh email

### 2.5 Cấu Hình Storage
1. Vào **Storage** → **New Bucket**
2. Tạo bucket: `avatars` (public)
3. Tạo bucket: `medical-files` (private)
4. Thiết lập policies cho từng bucket

### 2.6 Bật Realtime
1. Vào **Database → Replication**
2. Bật Realtime cho các bảng: `appointments`, `notifications`

## 3. Khởi Tạo Dự Án Flutter

### 3.1 Tạo Project Mới
```powershell
# Tạo Flutter project mới
flutter create --org com.yourname doctor_booking_app

# Di chuyển vào thư mục
cd doctor_booking_app

# Mở VS Code
code .
```

### 3.2 Cấu Hình `pubspec.yaml`
```yaml
name: doctor_booking_app
description: Smart Doctor Appointment Booking System
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ">=3.4.0 <4.0.0"
  flutter: ">=3.22.0"

dependencies:
  flutter:
    sdk: flutter

  # Supabase
  supabase_flutter: ^2.8.0

  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # Navigation
  auto_route: ^9.2.2

  # UI/UX
  flex_color_scheme: ^8.1.0
  flutter_screenutil: ^5.9.3
  flutter_svg: ^2.0.10
  flutter_animate: ^4.5.2
  lottie: ^3.1.3
  skeletonizer: ^1.4.3
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0

  # Calendar
  table_calendar: ^3.1.2
  add_2_calendar: ^3.0.1

  # Notifications
  flutter_local_notifications: ^18.0.1

  # Utilities
  intl: ^0.19.0
  equatable: ^2.0.7
  uuid: ^4.5.1
  shared_preferences: ^2.3.3
  json_annotation: ^4.9.0
  freezed_annotation: ^2.4.4
  url_launcher: ^6.3.1
  image_picker: ^1.1.2
  cupertino_icons: ^1.0.8
  iconsax_flutter: ^1.0.0

  # Network & Connectivity
  connectivity_plus: ^6.1.0          # Network monitoring
  http: ^1.2.2                       # HTTP client (connectivity check)

  # Secure Storage
  flutter_secure_storage: ^9.2.3     # Lưu tokens, sensitive data

  # Video Call (Telemedicine)
  agora_rtc_engine: ^6.3.2
  permission_handler: ^11.3.1

  # Payment
  webview_flutter: ^4.10.0

  # Charts (Analytics)
  fl_chart: ^0.69.0

  # Push Notifications (FCM - chỉ dùng messaging, KHÔNG dùng Firebase DB)
  firebase_core: ^3.8.0
  firebase_messaging: ^15.1.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  auto_route_generator: ^9.0.0
  build_runner: ^2.4.13
  json_serializable: ^6.8.0
  freezed: ^2.5.7
  riverpod_generator: ^2.6.3
  mockito: ^5.4.4
```

### 3.3 Cài Đặt Dependencies
```powershell
flutter pub get
```

### 3.4 Tạo Cấu Trúc Thư Mục
```powershell
# Tạo cấu trúc thư mục
mkdir lib\config
mkdir lib\config\theme
mkdir lib\config\routes
mkdir lib\core\di
mkdir lib\core\network
mkdir lib\core\error
mkdir lib\core\utils\extensions
mkdir lib\core\services
mkdir lib\data\models
mkdir lib\data\repositories
mkdir lib\data\datasources
mkdir lib\domain\entities
mkdir lib\domain\repositories
mkdir lib\domain\usecases\auth
mkdir lib\domain\usecases\appointment
mkdir lib\domain\usecases\doctor
mkdir lib\presentation\common\widgets
mkdir lib\presentation\common\splash
mkdir lib\presentation\common\onboarding
mkdir lib\presentation\common\auth
mkdir lib\presentation\patient\home\widgets
mkdir lib\presentation\patient\search
mkdir lib\presentation\patient\booking\widgets
mkdir lib\presentation\patient\calendar
mkdir lib\presentation\patient\profile
mkdir lib\presentation\patient\doctor_detail
mkdir lib\presentation\patient\reviews
mkdir lib\presentation\patient\medical_records
mkdir lib\presentation\patient\payment
mkdir lib\presentation\doctor\home
mkdir lib\presentation\doctor\calendar
mkdir lib\presentation\doctor\profile
mkdir lib\presentation\doctor\patients
mkdir lib\presentation\doctor\analytics
mkdir lib\presentation\doctor\settings
mkdir lib\presentation\chat\widgets
mkdir lib\presentation\telemedicine\widgets
mkdir lib\presentation\admin\dashboard
mkdir lib\presentation\admin\doctor_approval
mkdir lib\presentation\admin\user_management
mkdir lib\presentation\admin\speciality_management
mkdir lib\presentation\admin\appointment_overview
mkdir lib\presentation\admin\system_settings
mkdir lib\l10n
```

### 3.5 Cấu Hình Môi Trường (EnvConfig)

> ⚠️ **KHÔNG dùng hardcoded config**. Sử dụng `EnvConfig` để quản lý dev/staging/prod. Xem chi tiết tại `07_XU_LY_LOI_VA_EDGE_CASES.md` mục 4.2.

Tạo file `lib/config/env.dart`:
```dart
enum Environment { dev, staging, prod }

class EnvConfig {
  final Environment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String agoraAppId;
  // ... xem đầy đủ trong file 07

  static const dev = EnvConfig._(
    environment: Environment.dev,
    supabaseUrl: 'https://xxx-dev.supabase.co',
    supabaseAnonKey: 'dev-anon-key',
    agoraAppId: 'agora-dev-app-id',
    // ...
  );

  // staging, prod tương tự
}
```

### 3.6 Khởi Tạo Main
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Chọn environment
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  final config = switch (env) {
    'prod'    => EnvConfig.prod,
    'staging' => EnvConfig.staging,
    _         => EnvConfig.dev,
  };

  // 2. Khởi tạo Firebase (chỉ cho FCM push notifications)
  await Firebase.initializeApp();

  // 3. Khởi tạo Supabase (cơ sở dữ liệu chính)
  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
  );
  
  runApp(ProviderScope(child: DoctorBookingApp(config: config)));
}
```

## 4. Code Generation

### Chạy build_runner:
```powershell
# Generate code (models, routes, riverpod)
dart run build_runner build --delete-conflicting-outputs

# Hoặc watch mode (auto-generate khi thay đổi)
dart run build_runner watch --delete-conflicting-outputs
```

## 5. Chạy Ứng Dụng

```powershell
# Kiểm tra thiết bị
flutter devices

# Chạy debug
flutter run

# Chạy trên Chrome (web)
flutter run -d chrome

# Chạy trên Android emulator
flutter run -d emulator-5554
```

## 6. Thiết Lập Agora Video Call (Telemedicine)

### 6.1 Tạo Agora Project
1. Truy cập https://console.agora.io → **Sign Up / Login**
2. Tạo **New Project**:
   - **Project Name**: `doctor-booking`
   - **Authentication**: chọn **Secured mode (APP ID + Token)**
3. Lấy thông tin:
   - **App ID**: `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` (32 ký tự)
   - **App Certificate**: `yyyyyyyyyyyyyyyyyyyyyyyy` (để tạo token server-side)

### 6.2 Cấu Hình Android
Thêm vào `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.BLUETOOTH" />
```

Cập nhật `android/app/build.gradle`:
```gradle
android {
    compileSdk 34
    defaultConfig {
        minSdk 24  // Agora yêu cầu tối thiểu API 24
    }
}
```

### 6.3 Cấu Hình iOS
Thêm vào `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Cần camera để gọi video với bác sĩ</string>
<key>NSMicrophoneUsageDescription</key>
<string>Cần microphone để gọi video với bác sĩ</string>
```

### 6.4 Token Server (Edge Function)

> ⚠️ **QUAN TRỌNG**: Token phải được tạo server-side (Edge Function). KHÔNG tạo token ở client.

```typescript
// supabase/functions/generate-video-token/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { RtcTokenBuilder, RtcRole } from "npm:agora-access-token";

const AGORA_APP_ID = Deno.env.get("AGORA_APP_ID")!;
const AGORA_APP_CERTIFICATE = Deno.env.get("AGORA_APP_CERTIFICATE")!;

serve(async (req) => {
  const { channelName, uid, role } = await req.json();

  const tokenExpirationInSecond = 3600; // 1 hour
  const privilegeExpiredTs = Math.floor(Date.now() / 1000) + tokenExpirationInSecond;

  const agoraRole = role === "publisher" ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;

  const token = RtcTokenBuilder.buildTokenWithUid(
    AGORA_APP_ID,
    AGORA_APP_CERTIFICATE,
    channelName,
    uid,
    agoraRole,
    privilegeExpiredTs,
  );

  return new Response(JSON.stringify({ token, appId: AGORA_APP_ID }), {
    headers: { "Content-Type": "application/json" },
  });
});
```

### 6.5 Sử Dụng Trong Flutter

```dart
// 1. Xin quyền camera & mic
await [Permission.camera, Permission.microphone].request();

// 2. Lấy token từ Edge Function
final response = await supabase.functions.invoke('generate-video-token', body: {
  'channelName': 'appointment_${appointmentId}',
  'uid': userId.hashCode,
  'role': 'publisher',
});
final token = response.data['token'];
final appId = response.data['appId'];

// 3. Khởi tạo Agora engine
final engine = createAgoraRtcEngine();
await engine.initialize(RtcEngineContext(appId: appId));
await engine.enableVideo();
await engine.joinChannel(
  token: token,
  channelId: 'appointment_${appointmentId}',
  uid: userId.hashCode,
  options: ChannelMediaOptions(
    channelProfile: ChannelProfileType.channelProfileCommunication,
    clientRoleType: ClientRoleType.clientRoleBroadcaster,
  ),
);
```

### 6.6 Agora Pricing

| Tier | Giá (USD) | Ghi chú |
|---|---|---|
| **Free** | 10,000 phút/tháng | Đủ cho dev + staging |
| **Pay-as-you-go** | $0.99/1000 phút (video SD) | Production |

---

## 7. Thiết Lập Payment Gateways

### 7.1 MoMo
1. Đăng ký **MoMo Business** tại https://business.momo.vn
2. Tạo **Test App** → lấy: `partnerCode`, `accessKey`, `secretKey`
3. Sandbox endpoint: `https://test-payment.momo.vn/v2/gateway/api`
4. Cấu hình callback URL (Supabase Edge Function URL)

### 7.2 VNPay
1. Đăng ký **VNPay Merchant** tại https://sandbox.vnpayment.vn/merchantv2
2. Lấy: `vnp_TmnCode`, `vnp_HashSecret`
3. Sandbox endpoint: `https://sandbox.vnpayment.vn/paymentv2/vpcpay.html`
4. VNPay sử dụng WebView redirect → dùng `webview_flutter`

### 7.3 ZaloPay
1. Đăng ký tại https://docs.zalopay.vn
2. Lấy: `app_id`, `key1`, `key2`
3. Sandbox endpoint: `https://sb-openapi.zalopay.vn/v2/create`

> 💡 **Tip**: Tất cả payment gateways đều có sandbox mode. Bắt đầu bằng sandbox, chỉ chuyển production khi app sẵn sàng release.

---

## 8. Thiết Lập Push Notifications (FCM)

> ⚠️ **Quan trọng**: Firebase **CHỈ** được dùng cho FCM Push Notifications.
> **Supabase** vẫn là cơ sở dữ liệu chính. KHÔNG dùng Firestore, Firebase Auth, hay Firebase Storage.

### 8.1 Tạo Firebase Project
1. Truy cập https://console.firebase.google.com → **Add Project**
2. Tên project: `doctor-booking`
3. Bật **Google Analytics** (tùy chọn)
4. Tạo xong → vào **Project Settings**

### 8.2 Cấu Hình Android
1. Trong Firebase Console → **Add App** → chọn **Android**
2. Nhập package name: `com.yourname.doctor_booking_app`
3. Tải `google-services.json` → đặt vào `android/app/`
4. Cập nhật `android/build.gradle`:
```gradle
// android/build.gradle (project-level)
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```
5. Cập nhật `android/app/build.gradle`:
```gradle
// android/app/build.gradle (app-level)
apply plugin: 'com.google.gms.google-services'
```

### 8.3 Cấu Hình iOS
1. Trong Firebase Console → **Add App** → chọn **iOS**
2. Nhập Bundle ID: `com.yourname.doctorBookingApp`
3. Tải `GoogleService-Info.plist` → kéo vào `ios/Runner/` trong Xcode
4. Bật **Push Notifications** capability trong Xcode:
   - Target → Signing & Capabilities → + Capability → Push Notifications
   - Target → Signing & Capabilities → + Capability → Background Modes → Remote notifications

### 8.4 FCM Service trong Flutter

```dart
// lib/core/services/fcm_service.dart
class FCMService {
  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Xin quyền notification
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Lấy FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        // 3. Lưu token vào Supabase (bảng fcm_tokens)
        await _saveFCMToken(token);
      }

      // 4. Lắng nghe token refresh
      _messaging.onTokenRefresh.listen(_saveFCMToken);

      // 5. Xử lý notification khi app đang mở
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 6. Xử lý notification khi app ở background → tap mở
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    }
  }

  Future<void> _saveFCMToken(String token) async {
    await Supabase.instance.client.from('fcm_tokens').upsert({
      'user_id': Supabase.instance.client.auth.currentUser!.id,
      'token': token,
      'device_type': Platform.isIOS ? 'ios' : 'android',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
```

### 8.5 Gửi Notification từ Supabase Edge Function

```typescript
// supabase/functions/send-notification/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const FCM_SERVER_KEY = Deno.env.get("FCM_SERVER_KEY")!;

serve(async (req) => {
  const { token, title, body, data } = await req.json();

  const response = await fetch("https://fcm.googleapis.com/fcm/send", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `key=${FCM_SERVER_KEY}`,
    },
    body: JSON.stringify({
      to: token,
      notification: { title, body },
      data: data || {},
    }),
  });

  return new Response(JSON.stringify(await response.json()));
});
```

> 💡 **Lưu ý**: FCM Server Key được lưu trong Supabase Edge Function secrets,
> KHÔNG hardcode trong app Flutter.

---

## 9. Quy Trình Phát Triển

### Git Workflow
```
main (production)
├── develop (development)
│   ├── feature/auth
│   ├── feature/booking
│   ├── feature/doctor-profile
│   └── fix/booking-bug
```

### Commit Convention
```
feat: add booking calendar screen
fix: resolve date parsing issue
refactor: reorganize data layer
docs: update README
style: format code
test: add unit tests for auth
```

### Quy Trình Merge (Goal-Driven)
```
1. Viết test cases cho feature (DEFINE GOAL)
2. Implement feature (BUILD)
3. flutter analyze     → 0 errors
4. flutter test        → ALL PASS
5. Code review
6. Merge vào develop
7. Chuyển sang feature tiếp
```

---

## 10. Checklist Trước Khi Build

### Backend & Services
- [ ] Supabase project đã tạo (dev/staging/prod)
- [ ] Database schema đã chạy (bao gồm bảng chat, payments, video_call_sessions)
- [ ] RLS policies đã bật cho TẤT CẢ bảng
- [ ] Authentication providers đã cấu hình (Email + Google)
- [ ] Storage buckets đã tạo (avatars, medical-files)
- [ ] API keys đã cập nhật trong `EnvConfig`
- [ ] Google Sign-In OAuth đã cấu hình

### FCM (Push Notifications)
- [ ] Firebase project đã tạo
- [ ] `google-services.json` (Android) đã thêm
- [ ] `GoogleService-Info.plist` (iOS) đã thêm
- [ ] FCM Server Key đã lưu trong Supabase Edge Function secrets
- [ ] Edge Function `send-notification` đã deploy
- [ ] Test push notification thành công trên device

### Agora (Video Call)
- [ ] Agora project đã tạo
- [ ] App ID + App Certificate đã có
- [ ] Edge Function `generate-video-token` đã deploy
- [ ] Android permissions đã thêm (Camera, Mic)
- [ ] iOS permissions đã thêm (Info.plist)
- [ ] Test video call thành công trên 2 devices

### Payment Gateways
- [ ] MoMo sandbox account + credentials
- [ ] VNPay sandbox account + credentials
- [ ] ZaloPay sandbox account + credentials
- [ ] Edge Function `process-payment` đã deploy
- [ ] Callback URLs đã cấu hình đúng
- [ ] Test thanh toán thành công trên sandbox

### Flutter App
- [ ] Flutter dependencies đã cài (`flutter pub get`)
- [ ] Code generation đã chạy (`build_runner`)
- [ ] `flutter analyze` → 0 errors
- [ ] `flutter test` → ALL PASS
- [ ] App chạy thành công trên emulator/device

### Testing
- [ ] Unit tests coverage ≥ 80%
- [ ] Widget tests cho tất cả screens chính
- [ ] Edge case tests (offline, timeout, etc.)
- [ ] CI/CD pipeline đã cấu hình

---

## 11. Tóm Tắt Các File Tài Liệu

| File | Nội dung |
|---|---|
| `01_TONG_QUAN_DU_AN.md` | Phân tích code gốc, cấu trúc, dependencies, vấn đề |
| `02_KIEN_TRUC_CAU_TRUC.md` | Kiến trúc mới, cấu trúc thư mục, design system |
| `03_CO_SO_DU_LIEU.md` | ERD, SQL schema, RLS, Supabase config |
| `04_CHUC_NANG_NGHIEP_VU.md` | Chi tiết tất cả chức năng, màn hình, user flow |
| `05_KHAO_SAT_THI_TRUONG.md` | Đối thủ cạnh tranh, so sánh, SWOT, roadmap |
| `06_HUONG_DAN_TRIEN_KHAI.md` | Hướng dẫn setup Supabase, Agora, Payment, FCM, chạy app |
| `07_XU_LY_LOI_VA_EDGE_CASES.md` | Error handling, edge cases, bảo mật, environments |
| `08_CHIEN_LUOC_TESTING.md` | Testing strategy, TDD workflow, test cases, CI/CD |

---

> 💡 **Lưu ý quan trọng**: Khi bắt đầu trong thư mục mới, đọc tất cả 8 file `.md` trong thư mục `docs/` này là có thể hiểu đầy đủ yêu cầu, kiến trúc, bảo mật, testing strategy và bắt đầu xây dựng lại project từ đầu.
