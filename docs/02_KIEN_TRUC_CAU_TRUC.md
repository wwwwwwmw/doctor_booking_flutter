# 🏗️ KIẾN TRÚC & CẤU TRÚC - Doctor Booking App

## 1. Kiến trúc tổng quan

Ứng dụng theo mô hình **Clean Architecture đơn giản hóa** với 3 lớp:

```
┌─────────────────────────────────────────────────┐
│          PRESENTATION (UI + State)              │
│  Screens ← Riverpod Providers ← Repositories   │
├─────────────────────────────────────────────────┤
│              DATA (Models + Repos)              │
│  Repositories → Supabase Client → PostgreSQL    │
├─────────────────────────────────────────────────┤
│             CONFIG + CORE (Foundation)          │
│  Theme, Routes, Env, DI, Error Handling         │
└─────────────────────────────────────────────────┘
```

> **Lưu ý**: Domain layer (entities, usecases) đã được dự kiến nhưng chưa triển khai.
> Repositories gọi Supabase trực tiếp, không qua datasource abstraction.

## 2. Cây thư mục chi tiết

```
app/lib/
├── main.dart                          # Entry point (Supabase init, Riverpod, Error handling)
├── app.dart                           # Root MaterialApp (ScreenUtil, Theme, SplashScreen)
│
├── config/
│   ├── env.dart                       # EnvConfig (dev/staging/prod API keys)
│   ├── routes/
│   │   └── app_router.dart            # Route definitions (manual Navigator)
│   └── theme/
│       ├── app_colors.dart            # Centralized color palette
│       ├── app_text_styles.dart       # Typography tokens (Inter font)
│       ├── app_spacing.dart           # Spacing, border radius constants
│       ├── app_decorations.dart       # Card shadows, gradients, glass effects
│       └── app_theme.dart             # Light + Dark ThemeData
│
├── core/
│   ├── di/
│   │   └── di_providers.dart          # Supabase, Auth, Connectivity providers
│   ├── error/
│   │   └── failures.dart              # 8 sealed failure classes
│   └── services/
│       └── connectivity_service.dart  # Network monitoring
│
├── data/
│   ├── models/
│   │   ├── user_model.dart            # UserModel (id, email, fullName, role...)
│   │   ├── doctor_model.dart          # DoctorModel + SpecialityModel
│   │   ├── appointment_model.dart     # AppointmentModel (status, type enums)
│   │   ├── review_model.dart          # ReviewModel (rating, anonymous display)
│   │   ├── chat_model.dart            # ChatConversation + ChatMessage
│   │   └── payment_model.dart         # PaymentModel (method, status enums)
│   └── repositories/
│       ├── auth_repository.dart       # Login, Register, Profile, SignOut
│       ├── doctor_repository.dart     # Search, Filter, Top Doctors, Specialities
│       ├── appointment_repository.dart # CRUD, Slot Availability
│       ├── review_repository.dart     # Submit, Duplicate Prevention
│       ├── chat_repository.dart       # Realtime Stream, Mark Read
│       └── payment_repository.dart    # Payment Gateway Integration
│
├── domain/                            # (CHƯA TRIỂN KHAI)
│   ├── entities/                      # Trống
│   └── usecases/                      # Trống
│
└── presentation/
    ├── common/
    │   ├── auth/
    │   │   ├── login_screen.dart
    │   │   ├── register_screen.dart
    │   │   └── forgot_password_screen.dart
    │   ├── splash/splash_screen.dart
    │   ├── onboarding/onboarding_screen.dart
    │   ├── notifications/notifications_screen.dart
    │   ├── profile/profile_edit_screen.dart
    │   ├── settings/settings_screen.dart
    │   └── widgets/shared_widgets.dart     # Reusable widget library
    │
    ├── patient/
    │   ├── home/patient_home_screen.dart
    │   ├── search/search_doctors_screen.dart
    │   ├── doctor_detail/doctor_detail_screen.dart
    │   ├── booking/
    │   │   ├── book_appointment_screen.dart
    │   │   ├── appointment_detail_screen.dart
    │   │   └── booking_confirmation_screen.dart
    │   ├── calendar/patient_calendar_screen.dart
    │   ├── profile/patient_profile_screen.dart
    │   ├── medical_records/medical_records_screen.dart
    │   ├── reviews/write_review_screen.dart
    │   ├── favorites/favorite_doctors_screen.dart
    │   └── payment/
    │       ├── payment_checkout_screen.dart
    │       └── payment_history_screen.dart
    │
    ├── doctor/
    │   ├── home/doctor_home_screen.dart
    │   ├── calendar/doctor_calendar_screen.dart
    │   ├── patients/doctor_patients_screen.dart
    │   ├── profile/doctor_profile_screen.dart
    │   ├── analytics/doctor_analytics_screen.dart
    │   └── settings/doctor_settings_screen.dart
    │
    ├── admin/
    │   ├── admin_dashboard_screen.dart
    │   ├── admin_doctor_approval_screen.dart
    │   └── admin_user_management_screen.dart
    │
    ├── chat/
    │   ├── chat_inbox_screen.dart
    │   └── chat_conversation_screen.dart
    │
    └── telemedicine/
        ├── video_call_screen.dart
        └── waiting_room_screen.dart
```

## 3. State Management (Riverpod 2.x)

### Provider Types sử dụng
| Type | Sử dụng cho |
|---|---|
| `Provider` | Repositories (DI) |
| `FutureProvider` | Fetch data 1 lần (doctor list, profile) |
| `FutureProvider.family` | Fetch data theo param (doctor by ID) |
| `StreamProvider` | Realtime data (chat messages, auth state) |
| `StateProvider` | Simple state (search query, selected filter) |

### Ví dụ pattern
```dart
// DI - Repository provider
final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository(ref.watch(supabaseClientProvider));
});

// Data fetching
final topDoctorsProvider = FutureProvider<List<DoctorModel>>((ref) {
  return ref.watch(doctorRepositoryProvider).getTopDoctors(limit: 5);
});

// Parameterized query
final doctorDetailProvider = FutureProvider.family<DoctorModel, String>((ref, id) {
  return ref.watch(doctorRepositoryProvider).getDoctorById(id);
});
```

## 4. Design System

### Color Palette
- **Primary**: Teal (#0D9488) — Trust, Health
- **Secondary**: Indigo (#6366F1) — Modern, Tech
- **Accent**: Amber (#F59E0B) — Energy, Attention
- **Semantic**: Success/Warning/Error/Info colors
- **Gradients**: primaryGradient, heroGradient, secondaryGradient
- **Dark Mode**: Full dark color scheme

### Typography
- **Font**: Inter (Google Fonts)
- **Scale**: Display, H1-H4, Body L/M/S, Label, Caption, Button, Badge, Price

### Spacing
- **Base**: xs(4), sm(8), md(12), lg(16), xl(20), xxl(24), xxxl(32)
- **Components**: buttonHeight(52), inputHeight(56), appBarHeight(64), bottomNavHeight(72)
- **Border Radius**: xs(6), sm(8), md(12), lg(16), xl(20), xxl(24), round(100)

### Shared Widgets
| Widget | Dùng ở |
|---|---|
| `AppGradientHeader` | Home, Profile screens |
| `AppDoctorCard` | Search, Home, Favorites |
| `AppAppointmentCard` | Calendar, Dashboard |
| `AppStatCard` | Doctor/Admin Dashboard |
| `AppSectionHeader` | Home, detail screens |
| `AppEmptyState` | Empty list placeholders |
| `AppSearchBar` | Home, Search |
| `AppShimmerLoading` | Loading states |

## 5. Navigation

Sử dụng `Navigator.push()` trực tiếp (không dùng code-generated router):

```dart
// Navigate forward
Navigator.push(context, MaterialPageRoute(builder: (_) => const TargetScreen()));

// Navigate with params
Navigator.push(context, MaterialPageRoute(
  builder: (_) => DoctorDetailScreen(doctorId: doctor.id),
));

// Navigate and clear stack
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const LoginScreen()),
  (route) => false,
);
```

### Splash → Role-based routing:
- `patient` → PatientHomeScreen
- `doctor` → DoctorHomeScreen
- `admin` → PatientHomeScreen (tạm thời)
- Chưa login → OnboardingScreen

## 6. Dependencies chính (pubspec.yaml)

| Package | Version | Mục đích |
|---|---|---|
| `flutter_riverpod` | ^2.6.1 | State management |
| `supabase_flutter` | ^2.8.4 | Backend services |
| `google_fonts` | ^6.2.1 | Typography |
| `flutter_animate` | ^4.5.2 | Micro-animations |
| `flutter_screenutil` | ^5.9.3 | Responsive UI |
| `table_calendar` | ^3.1.3 | Calendar widget |
| `fl_chart` | ^0.70.2 | Charts (analytics) |
| `equatable` | ^2.0.7 | Model comparison |
| `intl` | ^0.19.0 | Date formatting |
| `agora_rtc_engine` | ^6.5.0 | Video call |
| `iconsax` | ^0.0.8 | Icon set |

## 7. Error Handling

Sử dụng sealed failure classes:
```dart
abstract class Failure {
  final String message;
}

class ServerFailure extends Failure {...}
class AuthFailure extends Failure {...}
class NetworkFailure extends Failure {...}
class CacheFailure extends Failure {...}
// ... (8 loại)
```

Repository catch Supabase exceptions → throw typed Failures → UI hiển thị error message.
