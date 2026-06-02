# 🚀 HƯỚNG DẪN THIẾT LẬP DỰ ÁN - DOCTOR BOOKING APP

## Mục lục
- [Bước 1: Supabase (Web Dashboard)](#bước-1-supabase)
- [Bước 2: Docker (Local Supabase - tuỳ chọn)](#bước-2-docker)
- [Bước 3: Flutter App](#bước-3-flutter-app)
- [Bước 4: Firebase (chỉ FCM)](#bước-4-firebase)
- [Bước 5: Agora (Video Call)](#bước-5-agora)
- [Bước 6: Payment Gateways](#bước-6-payment)
- [Checklist tổng hợp](#checklist)

---

## Bước 1: Supabase (Web Dashboard) {#bước-1-supabase}

### 1.1 Tạo Project
1. Truy cập https://supabase.com → **Start your project**
2. Đăng nhập bằng GitHub
3. Click **New Project**:
   - **Organization**: chọn hoặc tạo mới
   - **Name**: `doctor-booking-dev`
   - **Database Password**: tạo password mạnh → **LƯU LẠI**
   - **Region**: `Southeast Asia (Singapore)`
4. Chờ ~2 phút để project khởi tạo

### 1.2 Lấy API Keys
1. Vào **Project Settings** → **API**
2. Copy 2 giá trị:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGci...` (dài)
3. Mở file `app/lib/config/env.dart` → thay vào `EnvConfig.dev`:
```dart
static const dev = EnvConfig._(
  environment: Environment.dev,
  supabaseUrl: 'https://xxxxx.supabase.co',      // ← Paste URL
  supabaseAnonKey: 'eyJhbGci...',                 // ← Paste anon key
  // ...
);
```

### 1.3 Bật Authentication Providers
1. Vào **Authentication** → **Providers**
2. **Email**: đã bật sẵn (mặc định)
3. **Google**:
   - Bật toggle
   - Cần Google OAuth credentials (tạo tại https://console.cloud.google.com)
   - Paste Client ID và Client Secret

### 1.4 Chạy Database Schema
1. Vào **SQL Editor** → click **New query**
2. Copy toàn bộ SQL từ file `docs/03_CO_SO_DU_LIEU.md` → paste vào
3. Click **Run** (hoặc Ctrl+Enter)
4. Kiểm tra: vào **Table Editor** → phải thấy các bảng:
   - `users`, `doctors`, `specialities`, `appointments`
   - `reviews`, `medical_records`, `favorites`
   - `chat_conversations`, `chat_messages`
   - `payments`, `video_call_sessions`

### 1.5 Tạo SQL Schema (copy paste vào SQL Editor)

```sql
-- ============================================
-- 1. BẢNG USERS
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    date_of_birth DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'other')),
    blood_type TEXT,
    role TEXT NOT NULL DEFAULT 'patient' CHECK (role IN ('patient', 'doctor', 'admin')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 2. BẢNG SPECIALITIES (Dynamic, không hardcode)
-- ============================================
CREATE TABLE IF NOT EXISTS specialities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    name_vi TEXT NOT NULL,
    icon TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default specialities
INSERT INTO specialities (name, name_vi, icon) VALUES
('Cardiology', 'Tim mạch', 'heart'),
('Dermatology', 'Da liễu', 'skin'),
('Neurology', 'Thần kinh', 'brain'),
('Orthopedics', 'Chỉnh hình', 'bone'),
('Pediatrics', 'Nhi khoa', 'child'),
('Ophthalmology', 'Mắt', 'eye'),
('ENT', 'Tai Mũi Họng', 'ear'),
('Dentistry', 'Nha khoa', 'tooth'),
('General', 'Đa khoa', 'general'),
('Psychiatry', 'Tâm thần', 'mind');

-- ============================================
-- 3. BẢNG DOCTORS
-- ============================================
CREATE TABLE IF NOT EXISTS doctors (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    speciality_id UUID REFERENCES specialities(id),
    hospital TEXT,
    bio TEXT,
    experience_years INTEGER DEFAULT 0,
    consultation_fee DECIMAL(10,2) DEFAULT 0,
    rating_avg DECIMAL(3,2) DEFAULT 0,
    rating_count INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    is_available BOOLEAN DEFAULT true,
    working_hours JSONB DEFAULT '{"mon":{"start":"08:00","end":"17:00"},"tue":{"start":"08:00","end":"17:00"},"wed":{"start":"08:00","end":"17:00"},"thu":{"start":"08:00","end":"17:00"},"fri":{"start":"08:00","end":"17:00"}}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 4. BẢNG APPOINTMENTS
-- ============================================
CREATE TABLE IF NOT EXISTS appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES users(id),
    doctor_id UUID NOT NULL REFERENCES doctors(id),
    booking_date DATE NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled', 'no_show')),
    consultation_type TEXT DEFAULT 'in_person' CHECK (consultation_type IN ('in_person', 'video')),
    reason TEXT,
    notes TEXT,
    cancellation_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(doctor_id, start_time, status) -- Prevent double booking
);

-- ============================================
-- 5. BẢNG REVIEWS
-- ============================================
CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID UNIQUE REFERENCES appointments(id),
    patient_id UUID NOT NULL REFERENCES users(id),
    doctor_id UUID NOT NULL REFERENCES doctors(id),
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    is_anonymous BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 6. BẢNG MEDICAL RECORDS
-- ============================================
CREATE TABLE IF NOT EXISTS medical_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES users(id),
    doctor_id UUID REFERENCES doctors(id),
    appointment_id UUID REFERENCES appointments(id),
    diagnosis TEXT,
    prescription TEXT,
    notes TEXT,
    attachments JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 7. BẢNG FAVORITES
-- ============================================
CREATE TABLE IF NOT EXISTS favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES users(id),
    doctor_id UUID NOT NULL REFERENCES doctors(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(patient_id, doctor_id)
);

-- ============================================
-- 8. BẢNG CHAT
-- ============================================
CREATE TABLE IF NOT EXISTS chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID REFERENCES appointments(id),
    patient_id UUID NOT NULL REFERENCES users(id),
    doctor_id UUID NOT NULL REFERENCES doctors(id),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'closed')),
    last_message_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file')),
    file_url TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 9. BẢNG PAYMENTS
-- ============================================
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID NOT NULL REFERENCES appointments(id),
    patient_id UUID NOT NULL REFERENCES users(id),
    amount DECIMAL(12,2) NOT NULL,
    method TEXT NOT NULL CHECK (method IN ('payos', 'cash')),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'success', 'failed', 'refunded')),
    transaction_id TEXT,
    idempotency_key TEXT UNIQUE,
    payos_order_code TEXT,
    gateway_response JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 10. BẢNG VIDEO CALL SESSIONS
-- ============================================
CREATE TABLE IF NOT EXISTS video_call_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID NOT NULL REFERENCES appointments(id),
    channel_name TEXT NOT NULL,
    status TEXT DEFAULT 'waiting' CHECK (status IN ('waiting', 'active', 'ended')),
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    duration_minutes INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 11. BẢNG FCM TOKENS
-- ============================================
CREATE TABLE IF NOT EXISTS fcm_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    device_type TEXT CHECK (device_type IN ('ios', 'android', 'web')),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, token)
);

-- ============================================
-- 12. INDEXES
-- ============================================
CREATE INDEX idx_appointments_patient ON appointments(patient_id);
CREATE INDEX idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX idx_appointments_date ON appointments(booking_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_reviews_doctor ON reviews(doctor_id);
CREATE INDEX idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX idx_payments_appointment ON payments(appointment_id);
CREATE INDEX idx_doctors_speciality ON doctors(speciality_id);
CREATE INDEX idx_doctors_rating ON doctors(rating_avg DESC);

-- ============================================
-- 13. ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_call_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Users: can read all, update own
CREATE POLICY "Users can read all users" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (auth.uid() = id);

-- Doctors: anyone can read, only self can update
CREATE POLICY "Anyone can read doctors" ON doctors FOR SELECT USING (true);
CREATE POLICY "Doctors can update own" ON doctors FOR UPDATE USING (auth.uid() = id);

-- Specialities: anyone can read
ALTER TABLE specialities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read specialities" ON specialities FOR SELECT USING (true);

-- Appointments: involved parties only
CREATE POLICY "Users can read own appointments" ON appointments FOR SELECT
    USING (auth.uid() = patient_id OR auth.uid() = doctor_id);
CREATE POLICY "Patients can create appointments" ON appointments FOR INSERT
    WITH CHECK (auth.uid() = patient_id);
CREATE POLICY "Involved can update appointments" ON appointments FOR UPDATE
    USING (auth.uid() = patient_id OR auth.uid() = doctor_id);

-- Reviews: anyone can read, patient can create for own appointments
CREATE POLICY "Anyone can read reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Patients can create reviews" ON reviews FOR INSERT
    WITH CHECK (auth.uid() = patient_id);

-- Medical Records: involved parties only
CREATE POLICY "Users can read own records" ON medical_records FOR SELECT
    USING (auth.uid() = patient_id OR auth.uid() = doctor_id);
CREATE POLICY "Doctors can create records" ON medical_records FOR INSERT
    WITH CHECK (auth.uid() = doctor_id);

-- Favorites: own only
CREATE POLICY "Users can manage own favorites" ON favorites FOR ALL
    USING (auth.uid() = patient_id);

-- Chat: involved parties only
CREATE POLICY "Chat participants can read" ON chat_conversations FOR SELECT
    USING (auth.uid() = patient_id OR auth.uid() = doctor_id);
CREATE POLICY "Chat participants can read messages" ON chat_messages FOR SELECT
    USING (auth.uid() IN (SELECT patient_id FROM chat_conversations WHERE id = conversation_id)
        OR auth.uid() IN (SELECT doctor_id FROM chat_conversations WHERE id = conversation_id));
CREATE POLICY "Chat participants can send messages" ON chat_messages FOR INSERT
    WITH CHECK (auth.uid() = sender_id);

-- Payments: involved parties only
CREATE POLICY "Users can read own payments" ON payments FOR SELECT
    USING (auth.uid() = patient_id);
CREATE POLICY "Users can create own payments" ON payments FOR INSERT
    WITH CHECK (auth.uid() = patient_id);

-- Video sessions: involved parties
CREATE POLICY "Participants can read video sessions" ON video_call_sessions FOR SELECT
    USING (auth.uid() IN (
        SELECT patient_id FROM appointments WHERE id = appointment_id
        UNION SELECT doctor_id FROM appointments WHERE id = appointment_id
    ));

-- FCM tokens: own only
CREATE POLICY "Users can manage own tokens" ON fcm_tokens FOR ALL
    USING (auth.uid() = user_id);

-- ============================================
-- 14. REALTIME SUBSCRIPTIONS
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE appointments;
ALTER PUBLICATION supabase_realtime ADD TABLE video_call_sessions;

-- ============================================
-- 15. FUNCTIONS
-- ============================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_doctors_updated_at BEFORE UPDATE ON doctors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-update doctor rating when review is inserted
CREATE OR REPLACE FUNCTION update_doctor_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE doctors SET
        rating_avg = (SELECT AVG(rating) FROM reviews WHERE doctor_id = NEW.doctor_id),
        rating_count = (SELECT COUNT(*) FROM reviews WHERE doctor_id = NEW.doctor_id)
    WHERE id = NEW.doctor_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_rating_on_review AFTER INSERT OR UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_doctor_rating();
```

### 1.6 Tạo Storage Buckets
1. Vào **Storage** → **New bucket**
2. Tạo 2 buckets:
   - `avatars` — Public: **ON**
   - `medical-files` — Public: **OFF** (private)

### 1.7 Bật Realtime
1. Vào **Database** → **Replication**
2. Bật realtime cho: `chat_messages`, `appointments`, `video_call_sessions`

---

## Bước 2: Docker (Local Supabase - Tuỳ chọn) {#bước-2-docker}

> 💡 Bước này **tuỳ chọn**. Nếu bạn dùng Supabase Cloud (web) thì bỏ qua.
> Dùng Docker khi muốn phát triển offline hoặc test nhanh không cần internet.

### 2.1 Cài Supabase CLI
```powershell
# Cách 1: npm (nếu có Node.js)
npm install -g supabase

# Cách 2: scoop (Windows)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

### 2.2 Khởi tạo Supabase Local
```powershell
cd "c:\Users\LECOO\Desktop\New folder (2)"

# Init supabase config
supabase init

# Start Docker containers (cần Docker Desktop đang chạy)
supabase start
```

Output sẽ hiển thị:
```
Started supabase local development setup.

         API URL: http://127.0.0.1:54321
     GraphQL URL: http://127.0.0.1:54321/graphql/v1
          DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
      Studio URL: http://127.0.0.1:54323
    Inbucket URL: http://127.0.0.1:54324
        anon key: eyJh...
service_role key: eyJh...
```

### 2.3 Truy cập Local Studio
- Mở trình duyệt → `http://127.0.0.1:54323`
- Giao diện giống hệt Supabase Dashboard online
- Paste SQL schema từ bước 1.5 vào SQL Editor

### 2.4 Dùng Local URL trong App
Cập nhật `app/lib/config/env.dart`:
```dart
static const dev = EnvConfig._(
  environment: Environment.dev,
  supabaseUrl: 'http://127.0.0.1:54321',    // Local
  supabaseAnonKey: 'eyJh...',                // Từ output supabase start
  // ...
);
```

### 2.5 Dừng / Reset Docker
```powershell
# Dừng
supabase stop

# Reset toàn bộ (xoá data)
supabase stop --no-backup
supabase start
```

---

## Bước 3: Flutter App {#bước-3-flutter-app}

### 3.1 Cài Dependencies
```powershell
cd "c:\Users\LECOO\Desktop\New folder (2)\app"
flutter pub get
```

### 3.2 Chạy Web App
```powershell
flutter run -d chrome
```

### 3.3 Build Production Web
```powershell
flutter build web --release --dart-define=ENV=prod
```
Output: `build/web/` → deploy lên hosting

---

## Bước 4: Firebase (Chỉ FCM Push Notifications) {#bước-4-firebase}

> ⚠️ Firebase **CHỈ** dùng cho push notifications. Supabase là DB chính.

### 4.1 Tạo Firebase Project
1. Truy cập https://console.firebase.google.com
2. **Add project** → tên: `doctor-booking`
3. Bật/tắt Google Analytics tuỳ ý
4. Chờ tạo xong

### 4.2 Thêm Web App
1. Trong Firebase Console → **Project Settings** → **Add app** → chọn **Web** (</\>)
2. App nickname: `doctor-booking-web`
3. Copy config object
4. Cập nhật file `app/web/index.html` (thêm vào `<head>`):
```html
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js"></script>
<script>
  firebase.initializeApp({
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_BUCKET",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
  });
</script>
```

### 4.3 Tạo Service Worker
Tạo file `app/web/firebase-messaging-sw.js`:
```javascript
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "YOUR_API_KEY",
  projectId: "YOUR_PROJECT_ID",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
});

const messaging = firebase.messaging();
messaging.onBackgroundMessage((message) => {
  const { title, body } = message.notification;
  self.registration.showNotification(title, { body });
});
```

---

## Bước 5: Agora Video Call {#bước-5-agora}

### 5.1 Tạo Agora Account
1. Truy cập https://console.agora.io → Sign Up
2. Tạo **New Project**: `doctor-booking`
3. Auth: **Secured mode (APP ID + Token)**
4. Copy **App ID**

### 5.2 Cập nhật EnvConfig
```dart
agoraAppId: 'YOUR_AGORA_APP_ID',
```

### 5.3 Free Tier
- 10,000 phút video/tháng miễn phí
- Đủ cho development và testing

---

## Bước 6: PayOS (Cổng thanh toán) {#bước-6-payment}

### 6.1 Đăng ký PayOS
1. Truy cập https://payos.vn → Đăng ký tài khoản
2. Tạo **Payment Channel** cho dự án
3. Lấy 3 thông tin từ dashboard:
   - **Client ID**: `46670123-66ab-4662-967a-41f6f05302e1`
   - **API Key**: `4434d998-9797-46fc-9d3d-5d469e57e47f`
   - **Checksum Key**: `4b6f14d6ea597e5ab6d796f5f2ca56f82158c60240bda5cf5d1298682fd96b78`

### 6.2 PayOS hỗ trợ
- QR Code (quét từ app ngân hàng)
- Chuyển khoản ngân hàng
- Ví MoMo, ZaloPay, VNPay (qua PayOS gateway)
- Thẻ Visa/Mastercard

### 6.3 Tích hợp
- Sử dụng Supabase Edge Function `create-payos-payment` để tạo link thanh toán
- PayOS webhook gọi về Edge Function `payos-webhook` để cập nhật trạng thái

---

## Checklist Tổng Hợp {#checklist}

### ✅ Supabase
- [ ] Project tạo xong
- [ ] API URL + anon key đã copy
- [ ] SQL schema đã chạy (tất cả bảng)
- [ ] RLS policies đã active
- [ ] Storage buckets tạo xong (avatars, medical-files)
- [ ] Realtime bật cho chat_messages, appointments
- [ ] Auth providers bật (Email + Google)

### ✅ Docker (tuỳ chọn)
- [ ] Docker Desktop đang chạy
- [ ] Supabase CLI đã cài
- [ ] `supabase start` thành công
- [ ] Local Studio truy cập được (port 54323)

### ✅ Flutter App
- [ ] `flutter pub get` thành công
- [ ] EnvConfig đã cập nhật keys
- [ ] `flutter run -d chrome` chạy được
- [ ] Splash → Login screen hiển thị đúng

### ✅ Firebase (FCM)
- [ ] Firebase project tạo xong
- [ ] Web app config đã thêm vào index.html
- [ ] Service worker đã tạo

### ✅ Agora
- [ ] Agora account + project tạo xong
- [ ] App ID đã cập nhật trong EnvConfig

### ✅ PayOS
- [ ] PayOS account đã đăng ký
- [ ] Client ID, API Key, Checksum Key đã cập nhật trong EnvConfig
- [ ] Edge Function `create-payos-payment` đã deploy
- [ ] Webhook URL đã cấu hình trong PayOS dashboard
