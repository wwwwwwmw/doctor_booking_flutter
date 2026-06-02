# 🏥 TỔNG QUAN DỰ ÁN - Doctor Booking App

## 1. Giới thiệu

**Doctor Booking App** là ứng dụng di động đặt lịch khám bệnh trực tuyến, kết nối bệnh nhân với bác sĩ. Hỗ trợ đặt lịch, video call, chat trực tiếp, thanh toán online, và quản lý hồ sơ y tế.

### Tech Stack
| Thành phần | Công nghệ |
|---|---|
| **Framework** | Flutter 3.x (Dart) |
| **Backend** | Supabase (PostgreSQL, Auth, Realtime, Storage) |
| **State Management** | Riverpod 2.x |
| **Routing** | Navigator (manual) |
| **Theme** | Custom Design System (Material 3, Google Fonts Inter) |
| **Video Call** | Agora RTC Engine |
| **Payment** | PayOS (MoMo, VNPay, ZaloPay) |
| **UI Utilities** | flutter_screenutil, flutter_animate |

## 2. Kiến trúc

Clean Architecture đơn giản hóa:
- **Data Layer**: Models + Repositories (gọi Supabase trực tiếp)
- **Presentation Layer**: Screens + Riverpod Providers
- **Config**: Theme, Routes, Environment
- **Core**: DI, Error handling, Services

> **Lưu ý**: Domain layer (entities, usecases) chưa triển khai. Repositories gọi Supabase trực tiếp.

## 3. Tính năng chính

### Bệnh nhân (Patient)
- ✅ Đăng ký, đăng nhập (Email + Google OAuth)
- ✅ Quên mật khẩu (Supabase reset email)
- ✅ Tìm kiếm bác sĩ (theo tên, chuyên khoa, bệnh viện)
- ✅ Xem chi tiết bác sĩ (đánh giá, kinh nghiệm, phí khám)
- ✅ Đặt lịch khám (chọn ngày, giờ, hình thức)
- ✅ Xem chi tiết lịch hẹn
- ✅ Quản lý lịch hẹn (calendar view)
- ✅ Hồ sơ y tế
- ✅ Đánh giá bác sĩ
- ✅ Bác sĩ yêu thích
- ✅ Thanh toán (MoMo, VNPay, ZaloPay, tiền mặt)
- ✅ Lịch sử thanh toán
- ✅ Chat với bác sĩ (realtime)
- ✅ Video call
- ✅ Thông báo
- ✅ Cài đặt (theme, ngôn ngữ, thông báo)

### Bác sĩ (Doctor)
- ✅ Dashboard thống kê
- ✅ Quản lý lịch hẹn
- ✅ Quản lý bệnh nhân
- ✅ Cập nhật lịch làm việc
- ✅ Analytics (doanh thu, biểu đồ)
- ✅ Chat với bệnh nhân
- ✅ Video call
- ✅ Cài đặt bác sĩ
- ✅ Hồ sơ bác sĩ

### Admin
- ✅ Dashboard tổng quan
- ✅ Duyệt bác sĩ
- ✅ Quản lý người dùng

## 4. Danh sách Screens (30+)

### Common
| Screen | File | Mô tả |
|---|---|---|
| Splash | `splash_screen.dart` | Gradient splash + role-based routing |
| Onboarding | `onboarding_screen.dart` | 4-page animated slides |
| Login | `login_screen.dart` | Email/Password + Google OAuth |
| Register | `register_screen.dart` | Role selection + Supabase signup |
| Forgot Password | `forgot_password_screen.dart` | Email reset via Supabase |
| Settings | `settings_screen.dart` | Theme, Language, Notifications |
| Notifications | `notifications_screen.dart` | Type-colored notifications |
| Profile Edit | `profile_edit_screen.dart` | Avatar, Name, DOB, Gender |

### Patient
| Screen | File | Mô tả |
|---|---|---|
| Home | `patient_home_screen.dart` | Gradient header, search, specialities, top doctors |
| Search Doctors | `search_doctors_screen.dart` | Filter chips, text search, doctor cards |
| Doctor Detail | `doctor_detail_screen.dart` | Stats, reviews, book button |
| Book Appointment | `book_appointment_screen.dart` | Calendar, time slots, consultation type |
| Booking Confirmation | `booking_confirmation_screen.dart` | Success animation + summary |
| Appointment Detail | `appointment_detail_screen.dart` | Status, details, actions |
| Calendar | `patient_calendar_screen.dart` | TableCalendar with events |
| Profile | `patient_profile_screen.dart` | Gradient header, info, actions |
| Medical Records | `medical_records_screen.dart` | Expandable records |
| Write Review | `write_review_screen.dart` | 5-star, anonymous toggle |
| Favorites | `favorite_doctors_screen.dart` | Favorite list |
| Payment Checkout | `payment_checkout_screen.dart` | 4 methods |
| Payment History | `payment_history_screen.dart` | Transaction list |

### Doctor
| Screen | File | Mô tả |
|---|---|---|
| Home/Dashboard | `doctor_home_screen.dart` | Stats, today's appointments, quick actions |
| Calendar | `doctor_calendar_screen.dart` | Schedule, working hours |
| Patients | `doctor_patients_screen.dart` | Patient list |
| Profile | `doctor_profile_screen.dart` | Stats, verification |
| Analytics | `doctor_analytics_screen.dart` | Revenue chart, ratings |
| Settings | `doctor_settings_screen.dart` | Account, appointment settings |

### Admin
| Screen | File | Mô tả |
|---|---|---|
| Dashboard | `admin_dashboard_screen.dart` | Stats, charts, pending actions |
| Doctor Approval | `admin_doctor_approval_screen.dart` | Approve/Reject tabs |
| User Management | `admin_user_management_screen.dart` | Search, filter, CRUD |

### Telemedicine & Chat
| Screen | File | Mô tả |
|---|---|---|
| Video Call | `video_call_screen.dart` | PiP, controls, timer |
| Waiting Room | `waiting_room_screen.dart` | Device check, timer |
| Chat Inbox | `chat_inbox_screen.dart` | Conversation list |
| Chat Conversation | `chat_conversation_screen.dart` | Realtime messages |

## 5. Data Models (6)
| Model | Fields chính |
|---|---|
| `UserModel` | id, email, fullName, phone, role, avatarUrl, dateOfBirth, gender, bloodType |
| `DoctorModel` | id, specialityId, hospital, bio, experienceYears, consultationFee, ratingAvg, ratingCount, isVerified |
| `AppointmentModel` | id, patientId, doctorId, bookingDate, startTime, endTime, status, consultationType |
| `ReviewModel` | id, appointmentId, doctorId, rating, comment |
| `ChatModel` | ChatConversation + ChatMessage (conversation_id, sender, content, type) |
| `PaymentModel` | id, appointmentId, amount, paymentMethod, status, transactionId |

## 6. Design System

Ứng dụng sử dụng Design System thống nhất với các file:
- `app_colors.dart` — Color palette (Teal + Indigo gradient, semantic colors)
- `app_text_styles.dart` — Typography tokens (Inter font)
- `app_spacing.dart` — Spacing, border radius, icon/avatar sizes
- `app_decorations.dart` — Card shadows, gradients, glass effects
- `app_theme.dart` — Material ThemeData (Light + Dark mode)
- `shared_widgets.dart` — Reusable widgets (GradientHeader, DoctorCard, StatCard, etc.)

## 7. Backend (Supabase)

- **Auth**: Email/Password + Google OAuth
- **Database**: PostgreSQL với RLS policies
- **Realtime**: Chat messages, appointment updates
- **Storage**: Avatar uploads, medical documents
- **Edge Functions**: Notifications, payment processing (planned)

## 8. Cấu trúc thư mục
```
app/lib/
├── config/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_spacing.dart
│   │   ├── app_decorations.dart
│   │   └── app_theme.dart
│   ├── routes/app_router.dart
│   └── env.dart
├── core/
│   ├── di/di_providers.dart
│   ├── error/failures.dart
│   └── services/connectivity_service.dart
├── data/
│   ├── models/ (6 models)
│   └── repositories/ (6 repos)
├── domain/ (chưa triển khai)
└── presentation/
    ├── common/ (auth, splash, onboarding, settings, notifications, widgets)
    ├── patient/ (home, search, booking, calendar, profile, records, etc.)
    ├── doctor/ (home, calendar, patients, profile, analytics, settings)
    ├── admin/ (dashboard, approval, user management)
    ├── chat/ (inbox, conversation)
    └── telemedicine/ (video call, waiting room)
```
