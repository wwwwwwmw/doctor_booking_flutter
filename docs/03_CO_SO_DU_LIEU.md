# 🗄️ CƠ SỞ DỮ LIỆU - Supabase PostgreSQL Schema

## 1. Tổng Quan

Sử dụng **Supabase** (PostgreSQL) thay thế Firebase Firestore. Database được thiết kế theo chuẩn **3NF** (Third Normal Form) để tránh dữ liệu trùng lặp và đảm bảo tính toàn vẹn.

## 2. Entity Relationship Diagram (ERD)

```
┌──────────────┐       ┌──────────────────┐       ┌──────────────────┐
│    users     │       │   specialities   │       │     clinics      │
│──────────────│       │──────────────────│       │──────────────────│
│ id (PK, UUID)│       │ id (PK, UUID)    │       │ id (PK, UUID)    │
│ email        │       │ name             │       │ name             │
│ full_name    │       │ icon             │       │ address          │
│ phone        │       │ description      │       │ phone            │
│ avatar_url   │       │ created_at       │       │ latitude         │
│ role         │       └────────┬─────────┘       │ longitude        │
│ created_at   │                │                  │ image_url        │
│ updated_at   │                │                  │ created_at       │
└──────┬───────┘                │                  └────────┬─────────┘
       │                        │                           │
       │ 1:1                    │ N:1                       │ N:1
       ▼                        ▼                           ▼
┌──────────────────┐   ┌──────────────────┐
│    patients      │   │     doctors      │
│──────────────────│   │──────────────────│
│ id (PK, UUID)    │   │ id (PK, UUID)    │
│ user_id (FK)     │   │ user_id (FK)     │
│ date_of_birth    │   │ speciality_id(FK)│
│ gender           │   │ clinic_id (FK)   │
│ blood_type       │   │ bio              │
│ allergies        │   │ experience_years │
│ address          │   │ license_number   │
│ emergency_contact│   │ consultation_fee │
│ created_at       │   │ is_approved      │
│ updated_at       │   │ rating_avg       │
└──────┬───────────┘   │ total_reviews    │
       │               │ available_days   │
       │               │ working_hours    │
       │               │ created_at       │
       │               │ updated_at       │
       │               └──────┬───────────┘
       │                      │
       │    N:1                │    N:1
       ▼                      ▼
┌─────────────────────────────────────────┐
│              appointments               │
│─────────────────────────────────────────│
│ id (PK, UUID)                           │
│ patient_id (FK → patients.id)           │
│ doctor_id (FK → doctors.id)             │
│ booking_date (DATE)                     │
│ start_time (TIMESTAMPTZ)                │
│ end_time (TIMESTAMPTZ)                  │
│ status (ENUM: pending/confirmed/        │
│         cancelled/completed/no_show)    │
│ patient_note (TEXT)                     │
│ doctor_note (TEXT)                      │
│ cancellation_reason (TEXT)              │
│ cancelled_by (ENUM: patient/doctor)    │
│ consultation_type (ENUM: in_person/     │
│                    video/phone)         │
│ created_at                              │
│ updated_at                              │
└─────────────────────────────────────────┘
       │
       │ 1:1
       ▼
┌─────────────────────────────────────────┐
│              reviews                     │
│─────────────────────────────────────────│
│ id (PK, UUID)                           │
│ appointment_id (FK → appointments.id)   │
│ patient_id (FK → patients.id)           │
│ doctor_id (FK → doctors.id)             │
│ rating (INTEGER 1-5)                    │
│ comment (TEXT)                          │
│ created_at                              │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│          medical_records                 │
│─────────────────────────────────────────│
│ id (PK, UUID)                           │
│ patient_id (FK → patients.id)           │
│ doctor_id (FK → doctors.id)             │
│ appointment_id (FK → appointments.id)   │
│ diagnosis (TEXT)                        │
│ prescription (TEXT)                     │
│ notes (TEXT)                            │
│ attachments (JSONB - file URLs)         │
│ created_at                              │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│          notifications                   │
│─────────────────────────────────────────│
│ id (PK, UUID)                           │
│ user_id (FK → users.id)                 │
│ title (TEXT)                            │
│ body (TEXT)                             │
│ type (ENUM: appointment/reminder/       │
│       cancellation/review/system)       │
│ data (JSONB)                            │
│ is_read (BOOLEAN)                       │
│ created_at                              │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│         doctor_schedules                 │
│─────────────────────────────────────────│
│ id (PK, UUID)                           │
│ doctor_id (FK → doctors.id)             │
│ day_of_week (INTEGER 0-6)              │
│ start_time (TIME)                       │
│ end_time (TIME)                         │
│ slot_duration (INTEGER - minutes)       │
│ break_start (TIME)                      │
│ break_end (TIME)                        │
│ is_active (BOOLEAN)                     │
│ created_at                              │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│         fcm_tokens                       │
│─────────────────────────────────────────│
│ id (PK, UUID)                           │
│ user_id (FK → users.id)                 │
│ token (TEXT)                            │
│ device_type (TEXT)                      │
│ created_at                              │
│ updated_at                              │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│          favorites                       │
│─────────────────────────────────────────│
│ id (PK, UUID)                           │
│ patient_id (FK → patients.id)           │
│ doctor_id (FK → doctors.id)             │
│ created_at                              │
└─────────────────────────────────────────┘
```

## 3. SQL Schema (Supabase Migration)

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- ENUM TYPES
-- ============================================
CREATE TYPE user_role AS ENUM ('patient', 'doctor', 'admin');
CREATE TYPE appointment_status AS ENUM ('pending', 'confirmed', 'cancelled', 'completed', 'no_show');
CREATE TYPE consultation_type AS ENUM ('in_person', 'video', 'phone');
CREATE TYPE cancellation_by AS ENUM ('patient', 'doctor', 'system');
CREATE TYPE notification_type AS ENUM ('appointment', 'reminder', 'cancellation', 'review', 'system');
CREATE TYPE gender_type AS ENUM ('male', 'female', 'other');

-- ============================================
-- USERS TABLE (linked to Supabase Auth)
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role user_role NOT NULL DEFAULT 'patient',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- SPECIALITIES TABLE
-- ============================================
CREATE TABLE specialities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    name_vi TEXT,  -- Vietnamese name
    icon TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default specialities
INSERT INTO specialities (name, name_vi, icon) VALUES
    ('General Practice', 'Đa khoa', '🏥'),
    ('Cardiology', 'Tim mạch', '❤️'),
    ('Dermatology', 'Da liễu', '🧴'),
    ('Dentistry', 'Nha khoa', '🦷'),
    ('Ophthalmology', 'Nhãn khoa', '👁️'),
    ('Orthopedics', 'Chỉnh hình', '🦴'),
    ('Pediatrics', 'Nhi khoa', '👶'),
    ('Gynecology', 'Phụ sản', '🤰'),
    ('Neurology', 'Thần kinh', '🧠'),
    ('ENT', 'Tai Mũi Họng', '👂'),
    ('Psychiatry', 'Tâm thần', '🧘'),
    ('Nutrition', 'Dinh dưỡng', '🍎'),
    ('Physiotherapy', 'Vật lý trị liệu', '💪'),
    ('Pathology', 'Bệnh lý', '🔬'),
    ('Pharmacy', 'Dược', '💊');

-- ============================================
-- CLINICS TABLE
-- ============================================
CREATE TABLE clinics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    image_url TEXT,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- PATIENTS TABLE
-- ============================================
CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date_of_birth DATE,
    gender gender_type,
    blood_type TEXT,
    allergies TEXT[],
    address TEXT,
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- DOCTORS TABLE
-- ============================================
CREATE TABLE doctors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    speciality_id UUID NOT NULL REFERENCES specialities(id),
    clinic_id UUID REFERENCES clinics(id),
    bio TEXT,
    experience_years INTEGER DEFAULT 0,
    license_number TEXT,
    consultation_fee DECIMAL(10,2) DEFAULT 0,
    is_approved BOOLEAN DEFAULT FALSE,
    rating_avg DECIMAL(2,1) DEFAULT 0,
    total_reviews INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- DOCTOR SCHEDULES TABLE
-- ============================================
CREATE TABLE doctor_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    slot_duration INTEGER NOT NULL DEFAULT 30,  -- minutes
    break_start TIME,
    break_end TIME,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(doctor_id, day_of_week)
);

-- ============================================
-- APPOINTMENTS TABLE
-- ============================================
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id),
    doctor_id UUID NOT NULL REFERENCES doctors(id),
    booking_date DATE NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    status appointment_status NOT NULL DEFAULT 'pending',
    consultation_type consultation_type NOT NULL DEFAULT 'in_person',
    patient_note TEXT,
    doctor_note TEXT,
    cancellation_reason TEXT,
    cancelled_by cancellation_by,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- REVIEWS TABLE
-- ============================================
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID UNIQUE NOT NULL REFERENCES appointments(id),
    patient_id UUID NOT NULL REFERENCES patients(id),
    doctor_id UUID NOT NULL REFERENCES doctors(id),
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- MEDICAL RECORDS TABLE
-- ============================================
CREATE TABLE medical_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id),
    doctor_id UUID NOT NULL REFERENCES doctors(id),
    appointment_id UUID REFERENCES appointments(id),
    diagnosis TEXT,
    prescription TEXT,
    notes TEXT,
    attachments JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type notification_type NOT NULL DEFAULT 'system',
    data JSONB DEFAULT '{}'::jsonb,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- FCM TOKENS TABLE
-- ============================================
CREATE TABLE fcm_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    device_type TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, token)
);

-- ============================================
-- FAVORITES TABLE
-- ============================================
CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(patient_id, doctor_id)
);

-- ============================================
-- INDEXES
-- ============================================
CREATE INDEX idx_appointments_patient ON appointments(patient_id);
CREATE INDEX idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX idx_appointments_date ON appointments(booking_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_doctors_speciality ON doctors(speciality_id);
CREATE INDEX idx_doctors_approved ON doctors(is_approved);
CREATE INDEX idx_reviews_doctor ON reviews(doctor_id);
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);
CREATE INDEX idx_favorites_patient ON favorites(patient_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE fcm_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
CREATE POLICY "Users read own data" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users update own data" ON users FOR UPDATE USING (auth.uid() = id);

-- Patients can read their own data
CREATE POLICY "Patients read own" ON patients FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Patients update own" ON patients FOR UPDATE USING (user_id = auth.uid());

-- Doctors are readable by all authenticated users
CREATE POLICY "Doctors readable by all" ON doctors FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Doctors update own" ON doctors FOR UPDATE USING (user_id = auth.uid());

-- Appointments - patients and doctors can see their own
CREATE POLICY "Appointments own access" ON appointments FOR SELECT
    USING (
        patient_id IN (SELECT id FROM patients WHERE user_id = auth.uid())
        OR
        doctor_id IN (SELECT id FROM doctors WHERE user_id = auth.uid())
    );

-- Specialities readable by all
CREATE POLICY "Specialities public read" ON specialities FOR SELECT USING (true);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER patients_updated_at BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER doctors_updated_at BEFORE UPDATE ON doctors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER appointments_updated_at BEFORE UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Function to update doctor's average rating
CREATE OR REPLACE FUNCTION update_doctor_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE doctors SET
        rating_avg = (SELECT AVG(rating)::DECIMAL(2,1) FROM reviews WHERE doctor_id = NEW.doctor_id),
        total_reviews = (SELECT COUNT(*) FROM reviews WHERE doctor_id = NEW.doctor_id)
    WHERE id = NEW.doctor_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_rating_on_review
    AFTER INSERT OR UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_doctor_rating();

-- Function to auto-create user profile after signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'patient')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

## 4. Bảng Bổ Sung (Chat, Payment, Video Call)

### 4.1 ERD Bổ Sung

```
┌─────────────────────────────────────────┐
│         chat_conversations               │
│─────────────────────────────────────────│
│ id (PK, UUID)                           │
│ appointment_id (FK → appointments.id)   │
│ patient_id (FK → patients.id)           │
│ doctor_id (FK → doctors.id)             │
│ is_active (BOOLEAN)                     │
│ created_at                              │
│ updated_at                              │
└─────────────────────────────────────────┘
       │
       │ 1:N
       ▼
┌─────────────────────────────────────────┐
│           chat_messages                  │
│─────────────────────────────────────────│
│ id (PK, UUID)                           │
│ conversation_id (FK)                    │
│ sender_id (FK → users.id)               │
│ message_type (ENUM: text/image/file)    │
│ content (TEXT)                           │
│ file_url (TEXT)                          │
│ is_read (BOOLEAN)                       │
│ created_at                              │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│             payments                     │
│─────────────────────────────────────────│
│ id (PK, UUID)                           │
│ appointment_id (FK → appointments.id)   │
│ patient_id (FK → patients.id)           │
│ doctor_id (FK → doctors.id)             │
│ amount (DECIMAL)                        │
│ platform_fee (DECIMAL)                  │
│ doctor_amount (DECIMAL)                 │
│ payment_method (ENUM: momo/vnpay/       │
│                 zalopay/cash)            │
│ status (ENUM: pending/success/          │
│         failed/refunded)                │
│ transaction_id (TEXT)                   │
│ payment_data (JSONB)                    │
│ paid_at (TIMESTAMPTZ)                   │
│ created_at                              │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│         video_call_sessions              │
│─────────────────────────────────────────│
│ id (PK, UUID)                           │
│ appointment_id (FK → appointments.id)   │
│ channel_name (TEXT)                      │
│ started_by (FK → users.id)              │
│ started_at (TIMESTAMPTZ)                │
│ ended_at (TIMESTAMPTZ)                  │
│ duration_seconds (INTEGER)              │
│ call_quality_rating (INTEGER 1-5)       │
│ status (ENUM: waiting/active/ended)     │
│ created_at                              │
└─────────────────────────────────────────┘
```

### 4.2 SQL Schema Bổ Sung

```sql
-- ============================================
-- THÊM ENUM TYPES
-- ============================================
CREATE TYPE message_type AS ENUM ('text', 'image', 'file');
CREATE TYPE payment_method AS ENUM ('momo', 'vnpay', 'zalopay', 'cash');
CREATE TYPE payment_status AS ENUM ('pending', 'success', 'failed', 'refunded');
CREATE TYPE call_status AS ENUM ('waiting', 'active', 'ended');

-- ============================================
-- CHAT CONVERSATIONS TABLE
-- ============================================
CREATE TABLE chat_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID REFERENCES appointments(id),
    patient_id UUID NOT NULL REFERENCES patients(id),
    doctor_id UUID NOT NULL REFERENCES doctors(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(appointment_id)
);

-- ============================================
-- CHAT MESSAGES TABLE
-- ============================================
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id),
    message_type message_type NOT NULL DEFAULT 'text',
    content TEXT,
    file_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- PAYMENTS TABLE
-- ============================================
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID NOT NULL REFERENCES appointments(id),
    patient_id UUID NOT NULL REFERENCES patients(id),
    doctor_id UUID NOT NULL REFERENCES doctors(id),
    amount DECIMAL(12,2) NOT NULL,
    platform_fee DECIMAL(12,2) DEFAULT 0,
    doctor_amount DECIMAL(12,2) DEFAULT 0,
    payment_method payment_method NOT NULL,
    status payment_status NOT NULL DEFAULT 'pending',
    transaction_id TEXT,
    payment_data JSONB DEFAULT '{}'::jsonb,
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(appointment_id)
);

-- ============================================
-- VIDEO CALL SESSIONS TABLE
-- ============================================
CREATE TABLE video_call_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID NOT NULL REFERENCES appointments(id),
    channel_name TEXT NOT NULL UNIQUE,
    started_by UUID REFERENCES users(id),
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    duration_seconds INTEGER DEFAULT 0,
    call_quality_rating INTEGER CHECK (call_quality_rating BETWEEN 1 AND 5),
    status call_status NOT NULL DEFAULT 'waiting',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INDEXES BỔ SUNG
-- ============================================
CREATE INDEX idx_chat_conversations_patient ON chat_conversations(patient_id);
CREATE INDEX idx_chat_conversations_doctor ON chat_conversations(doctor_id);
CREATE INDEX idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX idx_chat_messages_sender ON chat_messages(sender_id);
CREATE INDEX idx_payments_patient ON payments(patient_id);
CREATE INDEX idx_payments_doctor ON payments(doctor_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_video_calls_appointment ON video_call_sessions(appointment_id);

-- ============================================
-- RLS BỔ SUNG
-- ============================================
ALTER TABLE chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_call_sessions ENABLE ROW LEVEL SECURITY;

-- Chat: chỉ patient và doctor trong conversation mới truy cập được
CREATE POLICY "Chat conversation access" ON chat_conversations FOR SELECT
    USING (
        patient_id IN (SELECT id FROM patients WHERE user_id = auth.uid())
        OR doctor_id IN (SELECT id FROM doctors WHERE user_id = auth.uid())
    );

CREATE POLICY "Chat messages access" ON chat_messages FOR SELECT
    USING (
        conversation_id IN (
            SELECT id FROM chat_conversations
            WHERE patient_id IN (SELECT id FROM patients WHERE user_id = auth.uid())
            OR doctor_id IN (SELECT id FROM doctors WHERE user_id = auth.uid())
        )
    );

-- Payments: chỉ patient và doctor liên quan mới xem được
CREATE POLICY "Payment own access" ON payments FOR SELECT
    USING (
        patient_id IN (SELECT id FROM patients WHERE user_id = auth.uid())
        OR doctor_id IN (SELECT id FROM doctors WHERE user_id = auth.uid())
    );

-- Realtime cho chat_messages và video_call_sessions
-- Bật trong Supabase Dashboard: Database → Replication → thêm chat_messages, video_call_sessions
```

---

## 5. Supabase Realtime Subscriptions

### Appointments (Real-time updates)
```dart
// Listen to appointment changes for a doctor
supabase
  .from('appointments')
  .stream(primaryKey: ['id'])
  .eq('doctor_id', doctorId)
  .listen((data) => ...);

// Listen to new notifications
supabase
  .from('notifications')
  .stream(primaryKey: ['id'])
  .eq('user_id', userId)
  .order('created_at')
  .listen((data) => ...);
```

### Chat Messages (Real-time)
```dart
// Listen to new messages in a conversation
supabase
  .from('chat_messages')
  .stream(primaryKey: ['id'])
  .eq('conversation_id', conversationId)
  .order('created_at')
  .listen((data) => ...);
```

### Video Call Status (Real-time)
```dart
// Listen to video call session changes
supabase
  .from('video_call_sessions')
  .stream(primaryKey: ['id'])
  .eq('appointment_id', appointmentId)
  .listen((data) => ...);
```

## 6. Supabase Edge Functions (Server-side logic)

### Cần tạo Edge Functions cho:
1. **send-notification** - Gửi FCM push notification
2. **auto-remind** - Tự động nhắc nhở trước lịch hẹn (cron job)
3. **cancel-expired** - Tự động hủy lịch hẹn quá hạn chưa xác nhận
4. **generate-report** - Tạo báo cáo cho bác sĩ
5. **process-payment** - Xử lý callback từ MoMo/VNPay/ZaloPay
6. **refund-payment** - Xử lý hoàn tiền khi hủy lịch
7. **generate-video-token** - Tạo token Agora/Twilio cho video call
