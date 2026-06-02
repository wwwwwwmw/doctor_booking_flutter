# 🗄️ DOCTOR BOOKING - COMPLETE DATABASE SCHEMA
# Phiên bản: 1.0 | Cập nhật: 2026-05-25
# Mục đích: Tạo toàn bộ CSDL + Dữ liệu mẫu cho Doctor Booking App
# Database: Supabase (PostgreSQL)
#
# ⚡ CÁCH SỬ DỤNG:
#   1. Mở Supabase Dashboard → SQL Editor
#   2. Copy từng PHẦN và paste vào SQL Editor
#   3. Chạy theo thứ tự: PHẦN 1 → 2 → 3 → 4 → 5 → 6
#   4. Nếu muốn RESET toàn bộ: chạy PHẦN 0 trước
#
# 📌 QUY ƯỚC COMMENT:
#   -- 🔄 CẦN CHẠY LẠI KHI: mô tả điều kiện
#   -- ✅ AN TOÀN: có thể chạy nhiều lần (idempotent)
#   -- ⚠️ CHÚ Ý: lưu ý quan trọng
#   -- 🆕 MỚI THÊM: phần mới thêm so với schema cũ

---

## 📋 MỤC LỤC

| Phần | Nội dung | Khi nào cần chạy lại |
|------|----------|---------------------|
| 0 | Reset toàn bộ (DROP ALL) | Chỉ khi muốn xoá sạch |
| 1 | Tạo bảng (CREATE TABLE) | Khi thêm bảng/cột mới |
| 2 | Indexes | Khi thêm index mới |
| 3 | Row Level Security (RLS) | Khi sửa quyền truy cập |
| 4 | Functions & Triggers | Khi sửa logic tự động |
| 5 | Realtime & Storage | Khi thêm bảng realtime |
| 6 | Dữ liệu mẫu (Seed Data) | Khi muốn reset data test |

---

## PHẦN 0: RESET TOÀN BỘ (TUỲ CHỌN - CHỈ DÙNG KHI MUỐN XOÁ SẠCH)

> ⚠️ **CẢNH BÁO**: Phần này sẽ XOÁ TẤT CẢ dữ liệu. Chỉ chạy khi muốn làm lại từ đầu.

```sql
-- ============================================
-- ⚠️ RESET TOÀN BỘ DATABASE
-- ⚠️ SẼ XOÁ TẤT CẢ DỮ LIỆU - KHÔNG THỂ HOÀN TÁC
-- 🔄 CẦN CHẠY LẠI KHI: muốn làm lại từ đầu
-- ============================================

-- Xoá bảng theo thứ tự phụ thuộc (bảng con trước, bảng cha sau)
DROP TABLE IF EXISTS fcm_tokens CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS video_call_sessions CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS chat_conversations CASCADE;
DROP TABLE IF EXISTS favorites CASCADE;
DROP TABLE IF EXISTS medical_records CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS doctors CASCADE;
DROP TABLE IF EXISTS specialities CASCADE;
DROP TABLE IF EXISTS users CASCADE;
```

---

## PHẦN 1: TẠO BẢNG (CREATE TABLES)

> ✅ **AN TOÀN**: Dùng `IF NOT EXISTS` nên có thể chạy nhiều lần.

```sql
-- ============================================
-- PHẦN 1: TẠO TẤT CẢ CÁC BẢNG
-- ✅ AN TOÀN: có thể chạy lại nhiều lần
-- 🔄 CẦN CHẠY LẠI KHI: thêm bảng mới hoặc sửa cấu trúc
-- ============================================

-- ============================================
-- 1.1 BẢNG USERS (Người dùng - bảng gốc)
-- Lưu thông tin tất cả người dùng: bệnh nhân, bác sĩ, admin
-- Liên kết với Supabase Auth qua cột id
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
-- 1.2 BẢNG SPECIALITIES (Chuyên khoa)
-- Dữ liệu public, ai cũng xem được
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

-- Thêm chuyên khoa mặc định (bỏ qua nếu đã tồn tại)
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
('Psychiatry', 'Tâm thần', 'mind')
ON CONFLICT DO NOTHING;

-- ============================================
-- 1.3 BẢNG DOCTORS (Thông tin bác sĩ)
-- PK = users.id (1 user : 1 doctor)
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
    working_hours JSONB DEFAULT '{
        "mon":{"start":"08:00","end":"17:00"},
        "tue":{"start":"08:00","end":"17:00"},
        "wed":{"start":"08:00","end":"17:00"},
        "thu":{"start":"08:00","end":"17:00"},
        "fri":{"start":"08:00","end":"17:00"}
    }',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 1.4 BẢNG APPOINTMENTS (Lịch hẹn khám)
-- patient_id → users.id (người đặt lịch)
-- doctor_id  → doctors.id = users.id (bác sĩ)
-- ============================================
CREATE TABLE IF NOT EXISTS appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES users(id),
    doctor_id UUID NOT NULL REFERENCES doctors(id),
    booking_date DATE NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled', 'no_show')),
    consultation_type TEXT DEFAULT 'in_person'
        CHECK (consultation_type IN ('in_person', 'video')),
    reason TEXT,
    notes TEXT,
    cancellation_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(doctor_id, start_time, status)  -- Tránh đặt trùng slot
);

-- ============================================
-- 1.5 BẢNG REVIEWS (Đánh giá bác sĩ)
-- Dữ liệu public, ai cũng xem được
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
-- 1.6 BẢNG MEDICAL_RECORDS (Hồ sơ y tế)
-- 🔒 PRIVATE: chỉ bệnh nhân và bác sĩ liên quan mới xem được
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
-- 1.7 BẢNG FAVORITES (Bác sĩ yêu thích)
-- 🔒 PRIVATE: mỗi user chỉ thấy favorites của mình
-- ============================================
CREATE TABLE IF NOT EXISTS favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES users(id),
    doctor_id UUID NOT NULL REFERENCES doctors(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(patient_id, doctor_id)
);

-- ============================================
-- 1.8 BẢNG CHAT_CONVERSATIONS (Cuộc hội thoại)
-- 🔒 PRIVATE: chỉ 2 người trong cuộc hội thoại
-- ============================================
CREATE TABLE IF NOT EXISTS chat_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID REFERENCES appointments(id),
    patient_id UUID NOT NULL REFERENCES users(id),
    doctor_id UUID NOT NULL REFERENCES users(id),  -- ⚠️ ref users(id) vì doctors.id = users.id
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'closed')),
    last_message_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 1.9 BẢNG CHAT_MESSAGES (Tin nhắn)
-- 🔒 PRIVATE: chỉ người trong cuộc hội thoại
-- ============================================
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
-- 1.10 BẢNG PAYMENTS (Thanh toán)
-- 🔒 PRIVATE: chỉ bệnh nhân liên quan
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
-- 1.11 BẢNG NOTIFICATIONS (Thông báo)
-- 🆕 MỚI THÊM: bảng này bị thiếu trong schema cũ
-- 🔒 PRIVATE: mỗi user chỉ thấy thông báo của mình
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'system'
        CHECK (type IN ('appointment', 'reminder', 'cancellation', 'review', 'chat', 'payment', 'system')),
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 1.12 BẢNG VIDEO_CALL_SESSIONS (Phiên video call)
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
-- 1.13 BẢNG FCM_TOKENS (Token push notification)
-- ============================================
CREATE TABLE IF NOT EXISTS fcm_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    device_type TEXT CHECK (device_type IN ('ios', 'android', 'web')),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, token)
);
```

---

## PHẦN 2: INDEXES

> ✅ **AN TOÀN**: Dùng `IF NOT EXISTS` nên có thể chạy nhiều lần.

```sql
-- ============================================
-- PHẦN 2: TẠO INDEXES
-- ✅ AN TOÀN: có thể chạy lại nhiều lần
-- 🔄 CẦN CHẠY LẠI KHI: thêm index mới để tối ưu truy vấn
-- ============================================

-- Appointments
CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(booking_date);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);

-- Doctors
CREATE INDEX IF NOT EXISTS idx_doctors_speciality ON doctors(speciality_id);
CREATE INDEX IF NOT EXISTS idx_doctors_rating ON doctors(rating_avg DESC);
CREATE INDEX IF NOT EXISTS idx_doctors_verified ON doctors(is_verified) WHERE is_verified = true;

-- Reviews
CREATE INDEX IF NOT EXISTS idx_reviews_doctor ON reviews(doctor_id);
CREATE INDEX IF NOT EXISTS idx_reviews_patient ON reviews(patient_id);

-- Medical Records
CREATE INDEX IF NOT EXISTS idx_medical_records_patient ON medical_records(patient_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_doctor ON medical_records(doctor_id);

-- Favorites
CREATE INDEX IF NOT EXISTS idx_favorites_patient ON favorites(patient_id);
CREATE INDEX IF NOT EXISTS idx_favorites_doctor ON favorites(doctor_id);

-- Chat
CREATE INDEX IF NOT EXISTS idx_chat_conv_patient ON chat_conversations(patient_id);
CREATE INDEX IF NOT EXISTS idx_chat_conv_doctor ON chat_conversations(doctor_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender ON chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created ON chat_messages(conversation_id, created_at DESC);

-- Payments
CREATE INDEX IF NOT EXISTS idx_payments_appointment ON payments(appointment_id);
CREATE INDEX IF NOT EXISTS idx_payments_patient ON payments(patient_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);

-- Notifications
-- 🆕 MỚI THÊM
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(user_id, created_at DESC);

-- FCM Tokens
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_user ON fcm_tokens(user_id);

-- Video Call
CREATE INDEX IF NOT EXISTS idx_video_calls_appointment ON video_call_sessions(appointment_id);
```

---

## PHẦN 3: ROW LEVEL SECURITY (RLS)

> ⚠️ **LƯU Ý**: DROP POLICY trước CREATE để tránh lỗi trùng tên.
> Phần này cần chạy lại khi sửa quyền truy cập dữ liệu.

```sql
-- ============================================
-- PHẦN 3: ROW LEVEL SECURITY
-- ⚠️ DROP rồi CREATE lại toàn bộ policies
-- 🔄 CẦN CHẠY LẠI KHI: sửa quyền truy cập dữ liệu
-- ============================================

-- ========================
-- 3.1 BẬT RLS CHO TẤT CẢ BẢNG
-- ========================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE specialities ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_call_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE fcm_tokens ENABLE ROW LEVEL SECURITY;

-- ========================
-- 3.2 USERS
-- Ai cũng đọc được (để hiện tên bác sĩ, bệnh nhân)
-- Chỉ sửa profile của mình
-- ========================
DROP POLICY IF EXISTS "Users can read all users" ON users;
CREATE POLICY "Users can read all users" ON users
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON users;
CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON users;
CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- ========================
-- 3.3 SPECIALITIES
-- 🌍 PUBLIC: ai cũng đọc được
-- ========================
DROP POLICY IF EXISTS "Anyone can read specialities" ON specialities;
CREATE POLICY "Anyone can read specialities" ON specialities
    FOR SELECT USING (true);

-- ========================
-- 3.4 DOCTORS
-- 🌍 PUBLIC: ai cũng đọc được (để tìm kiếm bác sĩ)
-- Chỉ bác sĩ đó mới sửa được profile
-- ========================
DROP POLICY IF EXISTS "Anyone can read doctors" ON doctors;
CREATE POLICY "Anyone can read doctors" ON doctors
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Doctors can update own" ON doctors;
CREATE POLICY "Doctors can update own" ON doctors
    FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Doctors can insert own" ON doctors;
CREATE POLICY "Doctors can insert own" ON doctors
    FOR INSERT WITH CHECK (auth.uid() = id);

-- ========================
-- 3.5 APPOINTMENTS
-- 🔒 PRIVATE: chỉ bệnh nhân và bác sĩ liên quan
-- ========================
DROP POLICY IF EXISTS "Users can read own appointments" ON appointments;
CREATE POLICY "Users can read own appointments" ON appointments
    FOR SELECT USING (auth.uid() = patient_id OR auth.uid() = doctor_id);

DROP POLICY IF EXISTS "Patients can create appointments" ON appointments;
CREATE POLICY "Patients can create appointments" ON appointments
    FOR INSERT WITH CHECK (auth.uid() = patient_id);

DROP POLICY IF EXISTS "Involved can update appointments" ON appointments;
CREATE POLICY "Involved can update appointments" ON appointments
    FOR UPDATE USING (auth.uid() = patient_id OR auth.uid() = doctor_id);

-- ========================
-- 3.6 REVIEWS
-- 🌍 PUBLIC đọc (để xem đánh giá bác sĩ)
-- 🔒 Chỉ bệnh nhân tạo review cho lịch hẹn của mình
-- ========================
DROP POLICY IF EXISTS "Anyone can read reviews" ON reviews;
CREATE POLICY "Anyone can read reviews" ON reviews
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Patients can create reviews" ON reviews;
CREATE POLICY "Patients can create reviews" ON reviews
    FOR INSERT WITH CHECK (auth.uid() = patient_id);

-- ========================
-- 3.7 MEDICAL RECORDS
-- 🔒 PRIVATE: chỉ bệnh nhân và bác sĩ liên quan
-- ========================
DROP POLICY IF EXISTS "Users can read own records" ON medical_records;
CREATE POLICY "Users can read own records" ON medical_records
    FOR SELECT USING (auth.uid() = patient_id OR auth.uid() = doctor_id);

DROP POLICY IF EXISTS "Doctors can create records" ON medical_records;
CREATE POLICY "Doctors can create records" ON medical_records
    FOR INSERT WITH CHECK (auth.uid() = doctor_id);

DROP POLICY IF EXISTS "Doctors can update records" ON medical_records;
CREATE POLICY "Doctors can update records" ON medical_records
    FOR UPDATE USING (auth.uid() = doctor_id);

-- ========================
-- 3.8 FAVORITES
-- 🔒 PRIVATE: mỗi user quản lý favorites của mình
-- ========================
DROP POLICY IF EXISTS "Users can manage own favorites" ON favorites;
CREATE POLICY "Users can manage own favorites" ON favorites
    FOR ALL USING (auth.uid() = patient_id);

-- ========================
-- 3.9 CHAT CONVERSATIONS
-- 🔒 PRIVATE: chỉ 2 người trong cuộc hội thoại
-- ========================
DROP POLICY IF EXISTS "Chat participants can read" ON chat_conversations;
CREATE POLICY "Chat participants can read" ON chat_conversations
    FOR SELECT USING (auth.uid() = patient_id OR auth.uid() = doctor_id);

DROP POLICY IF EXISTS "Chat participants can create" ON chat_conversations;
CREATE POLICY "Chat participants can create" ON chat_conversations
    FOR INSERT WITH CHECK (auth.uid() = patient_id OR auth.uid() = doctor_id);

DROP POLICY IF EXISTS "Chat participants can update" ON chat_conversations;
CREATE POLICY "Chat participants can update" ON chat_conversations
    FOR UPDATE USING (auth.uid() = patient_id OR auth.uid() = doctor_id);

-- ========================
-- 3.10 CHAT MESSAGES
-- 🔒 PRIVATE: chỉ người trong cuộc hội thoại
-- ========================
DROP POLICY IF EXISTS "Chat participants can read messages" ON chat_messages;
CREATE POLICY "Chat participants can read messages" ON chat_messages
    FOR SELECT USING (
        auth.uid() IN (SELECT patient_id FROM chat_conversations WHERE id = conversation_id)
        OR auth.uid() IN (SELECT doctor_id FROM chat_conversations WHERE id = conversation_id)
    );

DROP POLICY IF EXISTS "Chat participants can send messages" ON chat_messages;
CREATE POLICY "Chat participants can send messages" ON chat_messages
    FOR INSERT WITH CHECK (auth.uid() = sender_id);

DROP POLICY IF EXISTS "Chat participants can update messages" ON chat_messages;
CREATE POLICY "Chat participants can update messages" ON chat_messages
    FOR UPDATE USING (
        auth.uid() IN (SELECT patient_id FROM chat_conversations WHERE id = conversation_id)
        OR auth.uid() IN (SELECT doctor_id FROM chat_conversations WHERE id = conversation_id)
    );

-- ========================
-- 3.11 PAYMENTS
-- 🔒 PRIVATE: chỉ bệnh nhân liên quan
-- ========================
DROP POLICY IF EXISTS "Users can read own payments" ON payments;
CREATE POLICY "Users can read own payments" ON payments
    FOR SELECT USING (auth.uid() = patient_id);

DROP POLICY IF EXISTS "Users can create own payments" ON payments;
CREATE POLICY "Users can create own payments" ON payments
    FOR INSERT WITH CHECK (auth.uid() = patient_id);

DROP POLICY IF EXISTS "Users can update own payments" ON payments;
CREATE POLICY "Users can update own payments" ON payments
    FOR UPDATE USING (auth.uid() = patient_id);

-- ========================
-- 3.12 NOTIFICATIONS
-- 🆕 MỚI THÊM
-- 🔒 PRIVATE: mỗi user chỉ thấy thông báo của mình
-- ========================
DROP POLICY IF EXISTS "Users can read own notifications" ON notifications;
CREATE POLICY "Users can read own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- Cho phép system/functions tạo notification (dùng service_role)
DROP POLICY IF EXISTS "Service can insert notifications" ON notifications;
CREATE POLICY "Service can insert notifications" ON notifications
    FOR INSERT WITH CHECK (true);

-- ========================
-- 3.13 VIDEO CALL SESSIONS
-- ========================
DROP POLICY IF EXISTS "Participants can read video sessions" ON video_call_sessions;
CREATE POLICY "Participants can read video sessions" ON video_call_sessions
    FOR SELECT USING (
        auth.uid() IN (
            SELECT patient_id FROM appointments WHERE id = appointment_id
            UNION SELECT doctor_id FROM appointments WHERE id = appointment_id
        )
    );

DROP POLICY IF EXISTS "Participants can create video sessions" ON video_call_sessions;
CREATE POLICY "Participants can create video sessions" ON video_call_sessions
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Participants can update video sessions" ON video_call_sessions;
CREATE POLICY "Participants can update video sessions" ON video_call_sessions
    FOR UPDATE USING (true);

-- ========================
-- 3.14 FCM TOKENS
-- 🔒 PRIVATE: mỗi user quản lý token của mình
-- ========================
DROP POLICY IF EXISTS "Users can manage own tokens" ON fcm_tokens;
CREATE POLICY "Users can manage own tokens" ON fcm_tokens
    FOR ALL USING (auth.uid() = user_id);
```

---

## PHẦN 4: FUNCTIONS & TRIGGERS

> ✅ **AN TOÀN**: Dùng `CREATE OR REPLACE` nên có thể chạy nhiều lần.

```sql
-- ============================================
-- PHẦN 4: FUNCTIONS & TRIGGERS
-- ✅ AN TOÀN: CREATE OR REPLACE, chạy lại nhiều lần
-- 🔄 CẦN CHẠY LẠI KHI: sửa logic tự động
-- ============================================

-- ========================
-- 4.1 TỰ ĐỘNG CẬP NHẬT updated_at
-- Khi UPDATE bất kỳ row nào, updated_at tự động = NOW()
-- ========================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Gắn trigger cho các bảng cần theo dõi thời gian sửa
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_doctors_updated_at ON doctors;
CREATE TRIGGER update_doctors_updated_at
    BEFORE UPDATE ON doctors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_appointments_updated_at ON appointments;
CREATE TRIGGER update_appointments_updated_at
    BEFORE UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_payments_updated_at ON payments;
CREATE TRIGGER update_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ========================
-- 4.2 TỰ ĐỘNG CẬP NHẬT RATING BÁC SĨ
-- Khi thêm/sửa review → tính lại rating_avg và rating_count
-- ========================
CREATE OR REPLACE FUNCTION update_doctor_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE doctors SET
        rating_avg = COALESCE((SELECT AVG(rating)::DECIMAL(3,2) FROM reviews WHERE doctor_id = NEW.doctor_id), 0),
        rating_count = (SELECT COUNT(*) FROM reviews WHERE doctor_id = NEW.doctor_id)
    WHERE id = NEW.doctor_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_rating_on_review ON reviews;
CREATE TRIGGER update_rating_on_review
    AFTER INSERT OR UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_doctor_rating();

-- ========================
-- 4.3 TỰ ĐỘNG TẠO THÔNG BÁO KHI CÓ LỊCH HẸN MỚI
-- 🆕 MỚI THÊM
-- Khi INSERT appointment → tạo notification cho bác sĩ
-- ========================
CREATE OR REPLACE FUNCTION notify_new_appointment()
RETURNS TRIGGER AS $$
DECLARE
    v_patient_name TEXT;
    v_booking_str TEXT;
BEGIN
    SELECT full_name INTO v_patient_name FROM users WHERE id = NEW.patient_id;
    v_booking_str := TO_CHAR(NEW.start_time AT TIME ZONE 'Asia/Ho_Chi_Minh', 'HH24:MI DD/MM/YYYY');

    -- Thông báo cho bác sĩ
    INSERT INTO notifications (user_id, title, body, type, data)
    VALUES (
        NEW.doctor_id,
        'Lịch hẹn mới',
        'Bệnh nhân ' || v_patient_name || ' đặt lịch khám lúc ' || v_booking_str,
        'appointment',
        jsonb_build_object('appointment_id', NEW.id, 'patient_id', NEW.patient_id)
    );

    -- Thông báo cho bệnh nhân
    INSERT INTO notifications (user_id, title, body, type, data)
    VALUES (
        NEW.patient_id,
        'Đặt lịch thành công',
        'Lịch hẹn của bạn lúc ' || v_booking_str || ' đang chờ xác nhận',
        'appointment',
        jsonb_build_object('appointment_id', NEW.id, 'doctor_id', NEW.doctor_id)
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_new_appointment ON appointments;
CREATE TRIGGER on_new_appointment
    AFTER INSERT ON appointments
    FOR EACH ROW EXECUTE FUNCTION notify_new_appointment();

-- ========================
-- 4.4 TỰ ĐỘNG THÔNG BÁO KHI CẬP NHẬT TRẠNG THÁI LỊCH HẸN
-- 🆕 MỚI THÊM
-- ========================
CREATE OR REPLACE FUNCTION notify_appointment_status_change()
RETURNS TRIGGER AS $$
DECLARE
    v_doctor_name TEXT;
    v_title TEXT;
    v_body TEXT;
BEGIN
    -- Chỉ trigger khi status thay đổi
    IF OLD.status = NEW.status THEN
        RETURN NEW;
    END IF;

    SELECT full_name INTO v_doctor_name FROM users WHERE id = NEW.doctor_id;

    CASE NEW.status
        WHEN 'confirmed' THEN
            v_title := 'Lịch hẹn đã xác nhận';
            v_body := 'BS. ' || v_doctor_name || ' đã xác nhận lịch hẹn của bạn';
        WHEN 'cancelled' THEN
            v_title := 'Lịch hẹn đã huỷ';
            v_body := 'Lịch hẹn với BS. ' || v_doctor_name || ' đã bị huỷ';
        WHEN 'completed' THEN
            v_title := 'Khám hoàn tất';
            v_body := 'Buổi khám với BS. ' || v_doctor_name || ' đã hoàn tất. Hãy đánh giá trải nghiệm!';
        ELSE
            RETURN NEW;
    END CASE;

    INSERT INTO notifications (user_id, title, body, type, data)
    VALUES (
        NEW.patient_id,
        v_title,
        v_body,
        CASE WHEN NEW.status = 'cancelled' THEN 'cancellation' ELSE 'appointment' END,
        jsonb_build_object('appointment_id', NEW.id, 'status', NEW.status)
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_appointment_status_change ON appointments;
CREATE TRIGGER on_appointment_status_change
    AFTER UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION notify_appointment_status_change();

-- ========================
-- 4.5 TỰ ĐỘNG TẠO USER KHI ĐĂNG KÝ (Supabase Auth trigger)
-- Chạy khi có user mới đăng ký qua Supabase Auth
-- ========================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'role', 'patient')
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ⚠️ Trigger này gắn vào auth.users (bảng hệ thống Supabase)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

---

## PHẦN 5: REALTIME & STORAGE

```sql
-- ============================================
-- PHẦN 5: REALTIME SUBSCRIPTIONS
-- ✅ AN TOÀN: có thể chạy lại
-- 🔄 CẦN CHẠY LẠI KHI: thêm bảng cần realtime
-- ============================================

-- Bật realtime cho các bảng cần cập nhật real-time
-- ⚠️ Nếu lỗi "already in publication", bỏ qua là OK
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE appointments;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE video_call_sessions;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ============================================
-- STORAGE BUCKETS
-- Tạo qua Supabase Dashboard → Storage → New Bucket:
--   1. "avatars"       → Public: ON
--   2. "medical-files"  → Public: OFF (private)
-- ============================================
```

---

## PHẦN 6: DỮ LIỆU MẪU (SEED DATA)

> ⚠️ **LƯU Ý QUAN TRỌNG**:
> - Dữ liệu mẫu dùng UUID cố định để dễ tham chiếu
> - Mật khẩu test cho tất cả tài khoản: `Test@123456`
> - Chạy **PHẦN 6A trước** (tạo auth users), sau đó 6B → 6J theo thứ tự
> - Nếu muốn xoá seed data: chạy PHẦN 0 rồi chạy lại từ PHẦN 1

### PHẦN 6A: Tạo Auth Users (Tài khoản đăng nhập)

> ⚠️ Chạy trong **Supabase SQL Editor** (cần quyền service_role)

```sql
-- ============================================
-- 6A: TẠO AUTH USERS (tài khoản đăng nhập)
-- ⚠️ CHỈ CHẠY TRONG SUPABASE SQL EDITOR
-- 🔄 CẦN CHẠY LẠI KHI: reset dữ liệu test
-- ============================================

-- Xoá auth users cũ nếu tồn tại (seed data only)
DELETE FROM auth.users WHERE id IN (
    '11111111-aaaa-aaaa-aaaa-111111111111',
    '22222222-aaaa-aaaa-aaaa-222222222222',
    '33333333-aaaa-aaaa-aaaa-333333333333',
    '44444444-bbbb-bbbb-bbbb-444444444444',
    '55555555-bbbb-bbbb-bbbb-555555555555',
    '66666666-bbbb-bbbb-bbbb-666666666666',
    '77777777-bbbb-bbbb-bbbb-777777777777',
    '88888888-bbbb-bbbb-bbbb-888888888888',
    '99999999-cccc-cccc-cccc-999999999999'
);

-- === BỆNH NHÂN ===
-- Bệnh nhân 1: Nguyễn Văn An (patient1@test.com / Test@123456)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token)
VALUES ('00000000-0000-0000-0000-000000000000', '11111111-aaaa-aaaa-aaaa-111111111111', 'authenticated', 'authenticated',
    'patient1@test.com', crypt('Test@123456', gen_salt('bf')), NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Nguyễn Văn An","role":"patient"}'::jsonb,
    NOW(), NOW(), '');

-- Bệnh nhân 2: Trần Thị Bích Ngọc (patient2@test.com / Test@123456)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token)
VALUES ('00000000-0000-0000-0000-000000000000', '22222222-aaaa-aaaa-aaaa-222222222222', 'authenticated', 'authenticated',
    'patient2@test.com', crypt('Test@123456', gen_salt('bf')), NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Trần Thị Bích Ngọc","role":"patient"}'::jsonb,
    NOW(), NOW(), '');

-- Bệnh nhân 3: Lê Hoàng Cường (patient3@test.com / Test@123456)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token)
VALUES ('00000000-0000-0000-0000-000000000000', '33333333-aaaa-aaaa-aaaa-333333333333', 'authenticated', 'authenticated',
    'patient3@test.com', crypt('Test@123456', gen_salt('bf')), NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Lê Hoàng Cường","role":"patient"}'::jsonb,
    NOW(), NOW(), '');

-- === BÁC SĨ ===
-- Bác sĩ 1: BS. Phạm Minh Đức (doctor1@test.com / Test@123456)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token)
VALUES ('00000000-0000-0000-0000-000000000000', '44444444-bbbb-bbbb-bbbb-444444444444', 'authenticated', 'authenticated',
    'doctor1@test.com', crypt('Test@123456', gen_salt('bf')), NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Phạm Minh Đức","role":"doctor"}'::jsonb,
    NOW(), NOW(), '');

-- Bác sĩ 2: BS. Vũ Thị Hương (doctor2@test.com / Test@123456)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token)
VALUES ('00000000-0000-0000-0000-000000000000', '55555555-bbbb-bbbb-bbbb-555555555555', 'authenticated', 'authenticated',
    'doctor2@test.com', crypt('Test@123456', gen_salt('bf')), NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Vũ Thị Hương","role":"doctor"}'::jsonb,
    NOW(), NOW(), '');

-- Bác sĩ 3: BS. Đặng Quốc Hùng (doctor3@test.com / Test@123456)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token)
VALUES ('00000000-0000-0000-0000-000000000000', '66666666-bbbb-bbbb-bbbb-666666666666', 'authenticated', 'authenticated',
    'doctor3@test.com', crypt('Test@123456', gen_salt('bf')), NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Đặng Quốc Hùng","role":"doctor"}'::jsonb,
    NOW(), NOW(), '');

-- Bác sĩ 4: BS. Ngô Thanh Lan (doctor4@test.com / Test@123456)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token)
VALUES ('00000000-0000-0000-0000-000000000000', '77777777-bbbb-bbbb-bbbb-777777777777', 'authenticated', 'authenticated',
    'doctor4@test.com', crypt('Test@123456', gen_salt('bf')), NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Ngô Thanh Lan","role":"doctor"}'::jsonb,
    NOW(), NOW(), '');

-- Bác sĩ 5: BS. Hoàng Văn Nam (doctor5@test.com / Test@123456)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token)
VALUES ('00000000-0000-0000-0000-000000000000', '88888888-bbbb-bbbb-bbbb-888888888888', 'authenticated', 'authenticated',
    'doctor5@test.com', crypt('Test@123456', gen_salt('bf')), NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Hoàng Văn Nam","role":"doctor"}'::jsonb,
    NOW(), NOW(), '');

-- === ADMIN ===
-- Admin: admin@test.com / Test@123456
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token)
VALUES ('00000000-0000-0000-0000-000000000000', '99999999-cccc-cccc-cccc-999999999999', 'authenticated', 'authenticated',
    'admin@test.com', crypt('Test@123456', gen_salt('bf')), NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Admin Hệ Thống","role":"admin"}'::jsonb,
    NOW(), NOW(), '');

-- Tạo identity records cho auth
INSERT INTO auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
SELECT id, id, id, jsonb_build_object('sub', id, 'email', email), 'email', NOW(), NOW(), NOW()
FROM auth.users
WHERE id IN (
    '11111111-aaaa-aaaa-aaaa-111111111111',
    '22222222-aaaa-aaaa-aaaa-222222222222',
    '33333333-aaaa-aaaa-aaaa-333333333333',
    '44444444-bbbb-bbbb-bbbb-444444444444',
    '55555555-bbbb-bbbb-bbbb-555555555555',
    '66666666-bbbb-bbbb-bbbb-666666666666',
    '77777777-bbbb-bbbb-bbbb-777777777777',
    '88888888-bbbb-bbbb-bbbb-888888888888',
    '99999999-cccc-cccc-cccc-999999999999'
)
ON CONFLICT DO NOTHING;
```

### PHẦN 6B: Dữ liệu Users (Public profiles)

```sql
-- ============================================
-- 6B: PUBLIC USER PROFILES
-- Nếu trigger handle_new_user đã tạo users, phần này sẽ bỏ qua (ON CONFLICT)
-- ============================================

-- Bệnh nhân
INSERT INTO users (id, email, full_name, phone, date_of_birth, gender, blood_type, role) VALUES
('11111111-aaaa-aaaa-aaaa-111111111111', 'patient1@test.com', 'Nguyễn Văn An', '0901234567', '1990-05-15', 'male', 'A+', 'patient'),
('22222222-aaaa-aaaa-aaaa-222222222222', 'patient2@test.com', 'Trần Thị Bích Ngọc', '0912345678', '1995-08-22', 'female', 'O+', 'patient'),
('33333333-aaaa-aaaa-aaaa-333333333333', 'patient3@test.com', 'Lê Hoàng Cường', '0923456789', '1988-12-01', 'male', 'B+', 'patient')
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    phone = EXCLUDED.phone,
    date_of_birth = EXCLUDED.date_of_birth,
    gender = EXCLUDED.gender,
    blood_type = EXCLUDED.blood_type;

-- Bác sĩ (user profile)
INSERT INTO users (id, email, full_name, phone, gender, role) VALUES
('44444444-bbbb-bbbb-bbbb-444444444444', 'doctor1@test.com', 'Phạm Minh Đức', '0934567890', 'male', 'doctor'),
('55555555-bbbb-bbbb-bbbb-555555555555', 'doctor2@test.com', 'Vũ Thị Hương', '0945678901', 'female', 'doctor'),
('66666666-bbbb-bbbb-bbbb-666666666666', 'doctor3@test.com', 'Đặng Quốc Hùng', '0956789012', 'male', 'doctor'),
('77777777-bbbb-bbbb-bbbb-777777777777', 'doctor4@test.com', 'Ngô Thanh Lan', '0967890123', 'female', 'doctor'),
('88888888-bbbb-bbbb-bbbb-888888888888', 'doctor5@test.com', 'Hoàng Văn Nam', '0978901234', 'male', 'doctor')
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    phone = EXCLUDED.phone,
    gender = EXCLUDED.gender,
    role = EXCLUDED.role;

-- Admin
INSERT INTO users (id, email, full_name, role) VALUES
('99999999-cccc-cccc-cccc-999999999999', 'admin@test.com', 'Admin Hệ Thống', 'admin')
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, role = EXCLUDED.role;
```

### PHẦN 6C: Dữ liệu Doctors (Hồ sơ bác sĩ)

```sql
-- ============================================
-- 6C: DOCTOR PROFILES
-- ============================================

INSERT INTO doctors (id, speciality_id, hospital, bio, experience_years, consultation_fee, rating_avg, rating_count, is_verified) VALUES
(
    '44444444-bbbb-bbbb-bbbb-444444444444',
    (SELECT id FROM specialities WHERE name = 'Cardiology'),
    'Bệnh viện Chợ Rẫy',
    'Chuyên gia Tim mạch với hơn 15 năm kinh nghiệm. Tốt nghiệp Đại học Y Dược TP.HCM, tu nghiệp tại Nhật Bản. Chuyên điều trị bệnh mạch vành, tăng huyết áp, suy tim.',
    15, 350000, 4.85, 128, true
),
(
    '55555555-bbbb-bbbb-bbbb-555555555555',
    (SELECT id FROM specialities WHERE name = 'Pediatrics'),
    'Bệnh viện Nhi Đồng 1',
    'Bác sĩ Nhi khoa tận tâm. Tốt nghiệp Đại học Y Hà Nội, chuyên sâu dinh dưỡng trẻ em và các bệnh hô hấp ở trẻ nhỏ.',
    10, 280000, 4.92, 215, true
),
(
    '66666666-bbbb-bbbb-bbbb-666666666666',
    (SELECT id FROM specialities WHERE name = 'Dermatology'),
    'Bệnh viện Da liễu TP.HCM',
    'Chuyên khoa Da liễu - Thẩm mỹ. Kinh nghiệm điều trị mụn trứng cá, viêm da cơ địa, nấm da. Phương pháp điều trị kết hợp Đông - Tây y.',
    12, 300000, 4.78, 95, true
),
(
    '77777777-bbbb-bbbb-bbbb-777777777777',
    (SELECT id FROM specialities WHERE name = 'Neurology'),
    'Bệnh viện 115 TP.HCM',
    'Chuyên gia Thần kinh học. Chuyên điều trị đau đầu migraine, rối loạn giấc ngủ, bệnh Parkinson. Tốt nghiệp chuyên khoa II tại Đại học Y Dược TP.HCM.',
    8, 320000, 4.65, 72, true
),
(
    '88888888-bbbb-bbbb-bbbb-888888888888',
    (SELECT id FROM specialities WHERE name = 'ENT'),
    'Bệnh viện Tai Mũi Họng TP.HCM',
    'Bác sĩ Tai Mũi Họng giàu kinh nghiệm. Chuyên phẫu thuật nội soi mũi xoang, điều trị viêm amidan, điếc đột ngột. Từng tu nghiệp tại Hàn Quốc.',
    18, 380000, 4.90, 156, true
)
ON CONFLICT (id) DO UPDATE SET
    speciality_id = EXCLUDED.speciality_id,
    hospital = EXCLUDED.hospital,
    bio = EXCLUDED.bio,
    experience_years = EXCLUDED.experience_years,
    consultation_fee = EXCLUDED.consultation_fee,
    rating_avg = EXCLUDED.rating_avg,
    rating_count = EXCLUDED.rating_count,
    is_verified = EXCLUDED.is_verified;
```

### PHẦN 6D: Dữ liệu Appointments (Lịch hẹn)

```sql
-- ============================================
-- 6D: APPOINTMENTS (Lịch hẹn)
-- Tạo các lịch hẹn giữa bệnh nhân và bác sĩ
-- ============================================

-- Xoá appointments cũ của seed data
DELETE FROM appointments WHERE patient_id IN (
    '11111111-aaaa-aaaa-aaaa-111111111111',
    '22222222-aaaa-aaaa-aaaa-222222222222',
    '33333333-aaaa-aaaa-aaaa-333333333333'
);

-- An khám Tim mạch với BS. Đức → đã hoàn thành
INSERT INTO appointments (id, patient_id, doctor_id, booking_date, start_time, end_time, status, consultation_type, reason) VALUES
('aaaa0001-0000-0000-0000-000000000001',
 '11111111-aaaa-aaaa-aaaa-111111111111', '44444444-bbbb-bbbb-bbbb-444444444444',
 CURRENT_DATE - INTERVAL '30 days', (CURRENT_DATE - INTERVAL '30 days') + TIME '09:00', (CURRENT_DATE - INTERVAL '30 days') + TIME '09:30',
 'completed', 'in_person', 'Khám tổng quát tim mạch, hay bị đau ngực khi gắng sức');

-- An khám Da liễu với BS. Hùng → đã hoàn thành
INSERT INTO appointments (id, patient_id, doctor_id, booking_date, start_time, end_time, status, consultation_type, reason) VALUES
('aaaa0002-0000-0000-0000-000000000002',
 '11111111-aaaa-aaaa-aaaa-111111111111', '66666666-bbbb-bbbb-bbbb-666666666666',
 CURRENT_DATE - INTERVAL '15 days', (CURRENT_DATE - INTERVAL '15 days') + TIME '14:00', (CURRENT_DATE - INTERVAL '15 days') + TIME '14:30',
 'completed', 'in_person', 'Bị nổi mẩn đỏ ở cánh tay, ngứa nhiều về đêm');

-- An đặt lịch sắp tới với BS. Lan (Thần kinh) → đã xác nhận
INSERT INTO appointments (id, patient_id, doctor_id, booking_date, start_time, end_time, status, consultation_type, reason) VALUES
('aaaa0003-0000-0000-0000-000000000003',
 '11111111-aaaa-aaaa-aaaa-111111111111', '77777777-bbbb-bbbb-bbbb-777777777777',
 CURRENT_DATE + INTERVAL '3 days', (CURRENT_DATE + INTERVAL '3 days') + TIME '10:00', (CURRENT_DATE + INTERVAL '3 days') + TIME '10:30',
 'confirmed', 'video', 'Hay bị đau đầu migraine, mất ngủ kéo dài');

-- Bích Ngọc khám Nhi khoa (cho con) với BS. Hương → đã hoàn thành
INSERT INTO appointments (id, patient_id, doctor_id, booking_date, start_time, end_time, status, consultation_type, reason) VALUES
('aaaa0004-0000-0000-0000-000000000004',
 '22222222-aaaa-aaaa-aaaa-222222222222', '55555555-bbbb-bbbb-bbbb-555555555555',
 CURRENT_DATE - INTERVAL '20 days', (CURRENT_DATE - INTERVAL '20 days') + TIME '08:30', (CURRENT_DATE - INTERVAL '20 days') + TIME '09:00',
 'completed', 'in_person', 'Bé bị ho kéo dài 2 tuần, sốt nhẹ về chiều');

-- Bích Ngọc khám TMH với BS. Nam → đã hoàn thành
INSERT INTO appointments (id, patient_id, doctor_id, booking_date, start_time, end_time, status, consultation_type, reason) VALUES
('aaaa0005-0000-0000-0000-000000000005',
 '22222222-aaaa-aaaa-aaaa-222222222222', '88888888-bbbb-bbbb-bbbb-888888888888',
 CURRENT_DATE - INTERVAL '7 days', (CURRENT_DATE - INTERVAL '7 days') + TIME '15:00', (CURRENT_DATE - INTERVAL '7 days') + TIME '15:30',
 'completed', 'in_person', 'Viêm mũi dị ứng, nghẹt mũi thường xuyên');

-- Bích Ngọc đặt lịch tái khám Nhi → chờ xác nhận
INSERT INTO appointments (id, patient_id, doctor_id, booking_date, start_time, end_time, status, consultation_type, reason) VALUES
('aaaa0006-0000-0000-0000-000000000006',
 '22222222-aaaa-aaaa-aaaa-222222222222', '55555555-bbbb-bbbb-bbbb-555555555555',
 CURRENT_DATE + INTERVAL '5 days', (CURRENT_DATE + INTERVAL '5 days') + TIME '09:00', (CURRENT_DATE + INTERVAL '5 days') + TIME '09:30',
 'pending', 'in_person', 'Tái khám ho cho bé');

-- Cường khám Tim mạch với BS. Đức → đã hoàn thành
INSERT INTO appointments (id, patient_id, doctor_id, booking_date, start_time, end_time, status, consultation_type, reason) VALUES
('aaaa0007-0000-0000-0000-000000000007',
 '33333333-aaaa-aaaa-aaaa-333333333333', '44444444-bbbb-bbbb-bbbb-444444444444',
 CURRENT_DATE - INTERVAL '10 days', (CURRENT_DATE - INTERVAL '10 days') + TIME '11:00', (CURRENT_DATE - INTERVAL '10 days') + TIME '11:30',
 'completed', 'in_person', 'Kiểm tra huyết áp định kỳ, có tiền sử cao huyết áp gia đình');

-- Cường khám bị huỷ
INSERT INTO appointments (id, patient_id, doctor_id, booking_date, start_time, end_time, status, consultation_type, reason, cancellation_reason) VALUES
('aaaa0008-0000-0000-0000-000000000008',
 '33333333-aaaa-aaaa-aaaa-333333333333', '77777777-bbbb-bbbb-bbbb-777777777777',
 CURRENT_DATE - INTERVAL '5 days', (CURRENT_DATE - INTERVAL '5 days') + TIME '14:00', (CURRENT_DATE - INTERVAL '5 days') + TIME '14:30',
 'cancelled', 'video', 'Tư vấn đau đầu', 'Bệnh nhân bận việc đột xuất');
```

### PHẦN 6E: Dữ liệu Reviews (Đánh giá)

```sql
-- ============================================
-- 6E: REVIEWS (Đánh giá bác sĩ)
-- Chỉ tạo review cho appointments đã completed
-- ============================================

INSERT INTO reviews (appointment_id, patient_id, doctor_id, rating, comment) VALUES
('aaaa0001-0000-0000-0000-000000000001', '11111111-aaaa-aaaa-aaaa-111111111111', '44444444-bbbb-bbbb-bbbb-444444444444',
 5, 'Bác sĩ Đức rất tận tình, giải thích kỹ lưỡng về tình trạng tim mạch. Phòng khám sạch sẽ, không phải chờ đợi lâu. Rất hài lòng!'),

('aaaa0002-0000-0000-0000-000000000002', '11111111-aaaa-aaaa-aaaa-111111111111', '66666666-bbbb-bbbb-bbbb-666666666666',
 4, 'Bác sĩ Hùng chẩn đoán chính xác. Thuốc bôi hiệu quả sau 1 tuần. Chỉ hơi phải chờ lâu vì đông bệnh nhân.'),

('aaaa0004-0000-0000-0000-000000000004', '22222222-aaaa-aaaa-aaaa-222222222222', '55555555-bbbb-bbbb-bbbb-555555555555',
 5, 'Bác sĩ Hương rất nhẹ nhàng với trẻ nhỏ, bé nhà mình không sợ đi khám nữa. Bác sĩ tư vấn dinh dưỡng cho bé rất chi tiết.'),

('aaaa0005-0000-0000-0000-000000000005', '22222222-aaaa-aaaa-aaaa-222222222222', '88888888-bbbb-bbbb-bbbb-888888888888',
 5, 'BS. Nam rất chuyên nghiệp. Nội soi mũi nhanh gọn, giải thích rõ ràng kết quả. Kê thuốc hợp lý, hết nghẹt mũi sau 3 ngày.'),

('aaaa0007-0000-0000-0000-000000000007', '33333333-aaaa-aaaa-aaaa-333333333333', '44444444-bbbb-bbbb-bbbb-444444444444',
 4, 'Kiểm tra huyết áp rất cẩn thận. Bác sĩ cho uống thuốc và dặn dò chế độ ăn giảm muối. Sẽ quay lại tái khám.')
ON CONFLICT (appointment_id) DO NOTHING;
```

### PHẦN 6F: Dữ liệu Medical Records (Hồ sơ y tế)

```sql
-- ============================================
-- 6F: MEDICAL RECORDS (Hồ sơ y tế)
-- 🔒 Dữ liệu private, chỉ hiện cho đúng bệnh nhân
-- ============================================

INSERT INTO medical_records (patient_id, doctor_id, appointment_id, diagnosis, prescription, notes) VALUES
-- Hồ sơ của An
('11111111-aaaa-aaaa-aaaa-111111111111', '44444444-bbbb-bbbb-bbbb-444444444444', 'aaaa0001-0000-0000-0000-000000000001',
 'Hẹp van hai lá nhẹ, huyết áp bình thường',
 'Aspirin 81mg x 1 viên/ngày sau ăn sáng\nAtorvastatin 10mg x 1 viên/tối\nTái khám sau 3 tháng',
 'Siêu âm tim: EF 65%, van hai lá hở nhẹ độ I. Điện tâm đồ bình thường. Khuyên tập thể dục đều đặn 30 phút/ngày.'),

('11111111-aaaa-aaaa-aaaa-111111111111', '66666666-bbbb-bbbb-bbbb-666666666666', 'aaaa0002-0000-0000-0000-000000000002',
 'Viêm da cơ địa (Eczema)',
 'Hydrocortisone cream 1% bôi vùng tổn thương 2 lần/ngày\nCetirizine 10mg x 1 viên/tối\nDưỡng ẩm Cetaphil sau tắm',
 'Tổn thương dạng mảng đỏ, bong vảy ở cánh tay 2 bên. Không bội nhiễm. Tránh xà phòng có hương liệu. Tái khám sau 2 tuần.'),

-- Hồ sơ của Bích Ngọc
('22222222-aaaa-aaaa-aaaa-222222222222', '55555555-bbbb-bbbb-bbbb-555555555555', 'aaaa0004-0000-0000-0000-000000000004',
 'Viêm phế quản cấp ở trẻ em',
 'Ambroxol syrup 15mg/5ml x 5ml ngày 3 lần\nParacetamol syrup 250mg khi sốt > 38.5°C\nKhí dung Ventolin 2.5mg x 2 lần/ngày nếu khò khè',
 'Bé gái 4 tuổi, cân nặng 16kg. Ho có đàm trắng, sốt nhẹ 37.8°C. Phổi ran ẩm 2 bên. SpO2 98%. Không cần kháng sinh.'),

('22222222-aaaa-aaaa-aaaa-222222222222', '88888888-bbbb-bbbb-bbbb-888888888888', 'aaaa0005-0000-0000-0000-000000000005',
 'Viêm mũi dị ứng mãn tính',
 'Fluticasone xịt mũi 50mcg x 2 nhát/bên/ngày\nMontelukast 10mg x 1 viên/tối\nRửa mũi bằng nước muối sinh lý hàng ngày',
 'Nội soi mũi: niêm mạc cuốn dưới phù nề, dịch nhầy trong. Không polyp. Test dị ứng: dương tính với bụi nhà, phấn hoa.'),

-- Hồ sơ của Cường
('33333333-aaaa-aaaa-aaaa-333333333333', '44444444-bbbb-bbbb-bbbb-444444444444', 'aaaa0007-0000-0000-0000-000000000007',
 'Tăng huyết áp độ I, rối loạn lipid máu',
 'Amlodipine 5mg x 1 viên/sáng\nRosuvastatin 10mg x 1 viên/tối\nĐo huyết áp tại nhà 2 lần/ngày, ghi sổ theo dõi',
 'HA: 145/92 mmHg. Cholesterol total: 6.2 mmol/L, LDL: 4.1 mmol/L. BMI: 26.5. Khuyên giảm cân, ăn giảm muối, tập thể dục.')
ON CONFLICT DO NOTHING;
```

### PHẦN 6G: Dữ liệu Chat (Cuộc hội thoại & Tin nhắn)

```sql
-- ============================================
-- 6G: CHAT CONVERSATIONS & MESSAGES
-- 🔒 Dữ liệu private, chỉ hiện cho 2 người trong cuộc
-- ============================================

-- Cuộc hội thoại: An ↔ BS. Đức
INSERT INTO chat_conversations (id, patient_id, doctor_id, status, last_message_at) VALUES
('cccc0001-0000-0000-0000-000000000001',
 '11111111-aaaa-aaaa-aaaa-111111111111', '44444444-bbbb-bbbb-bbbb-444444444444',
 'active', NOW() - INTERVAL '2 hours')
ON CONFLICT DO NOTHING;

-- Cuộc hội thoại: An ↔ BS. Hùng
INSERT INTO chat_conversations (id, patient_id, doctor_id, status, last_message_at) VALUES
('cccc0002-0000-0000-0000-000000000002',
 '11111111-aaaa-aaaa-aaaa-111111111111', '66666666-bbbb-bbbb-bbbb-666666666666',
 'active', NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

-- Cuộc hội thoại: Bích Ngọc ↔ BS. Hương
INSERT INTO chat_conversations (id, patient_id, doctor_id, status, last_message_at) VALUES
('cccc0003-0000-0000-0000-000000000003',
 '22222222-aaaa-aaaa-aaaa-222222222222', '55555555-bbbb-bbbb-bbbb-555555555555',
 'active', NOW() - INTERVAL '30 minutes')
ON CONFLICT DO NOTHING;

-- Cuộc hội thoại: Bích Ngọc ↔ BS. Nam
INSERT INTO chat_conversations (id, patient_id, doctor_id, status, last_message_at) VALUES
('cccc0004-0000-0000-0000-000000000004',
 '22222222-aaaa-aaaa-aaaa-222222222222', '88888888-bbbb-bbbb-bbbb-888888888888',
 'active', NOW() - INTERVAL '3 days')
ON CONFLICT DO NOTHING;

-- Cuộc hội thoại: Cường ↔ BS. Đức
INSERT INTO chat_conversations (id, patient_id, doctor_id, status, last_message_at) VALUES
('cccc0005-0000-0000-0000-000000000005',
 '33333333-aaaa-aaaa-aaaa-333333333333', '44444444-bbbb-bbbb-bbbb-444444444444',
 'active', NOW() - INTERVAL '5 hours')
ON CONFLICT DO NOTHING;

-- === TIN NHẮN ===

-- Chat An ↔ BS. Đức
INSERT INTO chat_messages (conversation_id, sender_id, content, created_at) VALUES
('cccc0001-0000-0000-0000-000000000001', '11111111-aaaa-aaaa-aaaa-111111111111',
 'Chào bác sĩ, em muốn hỏi về kết quả siêu âm tim hôm trước ạ', NOW() - INTERVAL '3 hours'),
('cccc0001-0000-0000-0000-000000000001', '44444444-bbbb-bbbb-bbbb-444444444444',
 'Chào bạn An. Kết quả siêu âm tim của bạn bình thường, van hai lá chỉ hở nhẹ độ I, không đáng lo ngại.', NOW() - INTERVAL '2 hours 50 minutes'),
('cccc0001-0000-0000-0000-000000000001', '44444444-bbbb-bbbb-bbbb-444444444444',
 'Bạn nhớ uống thuốc đúng giờ và tái khám sau 3 tháng nhé.', NOW() - INTERVAL '2 hours 48 minutes'),
('cccc0001-0000-0000-0000-000000000001', '11111111-aaaa-aaaa-aaaa-111111111111',
 'Dạ em cảm ơn bác sĩ ạ. Em sẽ uống thuốc đều đặn ạ!', NOW() - INTERVAL '2 hours');

-- Chat An ↔ BS. Hùng
INSERT INTO chat_messages (conversation_id, sender_id, content, created_at) VALUES
('cccc0002-0000-0000-0000-000000000002', '11111111-aaaa-aaaa-aaaa-111111111111',
 'Bác sĩ ơi, em bôi kem Hydrocortisone được 1 tuần rồi, da đỡ ngứa nhiều ạ', NOW() - INTERVAL '1 day 2 hours'),
('cccc0002-0000-0000-0000-000000000002', '66666666-bbbb-bbbb-bbbb-666666666666',
 'Tốt lắm! Bạn tiếp tục bôi thêm 1 tuần nữa rồi chuyển sang chỉ dùng kem dưỡng ẩm thôi nhé.', NOW() - INTERVAL '1 day 1 hour'),
('cccc0002-0000-0000-0000-000000000002', '66666666-bbbb-bbbb-bbbb-666666666666',
 'Nhớ tránh gãi và tránh xà phòng có hương liệu. Nếu tái phát thì liên hệ lại mình nhé.', NOW() - INTERVAL '1 day');

-- Chat Bích Ngọc ↔ BS. Hương
INSERT INTO chat_messages (conversation_id, sender_id, content, created_at) VALUES
('cccc0003-0000-0000-0000-000000000003', '22222222-aaaa-aaaa-aaaa-222222222222',
 'Bác sĩ ơi, bé nhà em hết ho rồi nhưng vẫn còn sổ mũi ạ', NOW() - INTERVAL '1 hour'),
('cccc0003-0000-0000-0000-000000000003', '55555555-bbbb-bbbb-bbbb-555555555555',
 'Sổ mũi sau viêm phế quản là bình thường, có thể kéo dài 1-2 tuần. Mẹ rửa mũi cho bé bằng nước muối sinh lý ngày 3-4 lần nhé.', NOW() - INTERVAL '50 minutes'),
('cccc0003-0000-0000-0000-000000000003', '22222222-aaaa-aaaa-aaaa-222222222222',
 'Dạ em cảm ơn bác sĩ. Tuần sau em đưa bé tái khám ạ.', NOW() - INTERVAL '45 minutes'),
('cccc0003-0000-0000-0000-000000000003', '55555555-bbbb-bbbb-bbbb-555555555555',
 'Vâng, nhớ đặt lịch trước nhé. Nếu bé sốt lại hoặc khó thở thì đưa đến ngay nha!', NOW() - INTERVAL '30 minutes');

-- Chat Cường ↔ BS. Đức
INSERT INTO chat_messages (conversation_id, sender_id, content, created_at) VALUES
('cccc0005-0000-0000-0000-000000000005', '33333333-aaaa-aaaa-aaaa-333333333333',
 'Bác sĩ ơi, em đo huyết áp ở nhà sáng nay là 138/88 mmHg, có cao không ạ?', NOW() - INTERVAL '6 hours'),
('cccc0005-0000-0000-0000-000000000005', '44444444-bbbb-bbbb-bbbb-444444444444',
 'Còn hơi cao một chút. Bạn uống thuốc Amlodipine đều chưa? Nên đo 2 lần cách nhau 5 phút rồi lấy trung bình nhé.', NOW() - INTERVAL '5 hours 30 minutes'),
('cccc0005-0000-0000-0000-000000000005', '33333333-aaaa-aaaa-aaaa-333333333333',
 'Dạ em uống đều ạ. Để em đo lại theo hướng dẫn. Cảm ơn bác sĩ!', NOW() - INTERVAL '5 hours');
```

### PHẦN 6H: Dữ liệu Payments (Thanh toán)

```sql
-- ============================================
-- 6H: PAYMENTS (Lịch sử thanh toán)
-- 🔒 Dữ liệu private, chỉ hiện cho đúng bệnh nhân
-- ============================================

INSERT INTO payments (appointment_id, patient_id, amount, method, status, transaction_id, created_at) VALUES
-- Thanh toán của An
('aaaa0001-0000-0000-0000-000000000001', '11111111-aaaa-aaaa-aaaa-111111111111',
 350000, 'payos', 'success', 'TXN-20260425-001', CURRENT_DATE - INTERVAL '30 days'),
('aaaa0002-0000-0000-0000-000000000002', '11111111-aaaa-aaaa-aaaa-111111111111',
 300000, 'cash', 'success', NULL, CURRENT_DATE - INTERVAL '15 days'),
('aaaa0003-0000-0000-0000-000000000003', '11111111-aaaa-aaaa-aaaa-111111111111',
 320000, 'payos', 'pending', NULL, CURRENT_DATE),

-- Thanh toán của Bích Ngọc
('aaaa0004-0000-0000-0000-000000000004', '22222222-aaaa-aaaa-aaaa-222222222222',
 280000, 'payos', 'success', 'TXN-20260505-002', CURRENT_DATE - INTERVAL '20 days'),
('aaaa0005-0000-0000-0000-000000000005', '22222222-aaaa-aaaa-aaaa-222222222222',
 380000, 'payos', 'success', 'TXN-20260518-003', CURRENT_DATE - INTERVAL '7 days'),

-- Thanh toán của Cường
('aaaa0007-0000-0000-0000-000000000007', '33333333-aaaa-aaaa-aaaa-333333333333',
 350000, 'cash', 'success', NULL, CURRENT_DATE - INTERVAL '10 days'),
('aaaa0008-0000-0000-0000-000000000008', '33333333-aaaa-aaaa-aaaa-333333333333',
 320000, 'payos', 'refunded', 'TXN-20260520-004', CURRENT_DATE - INTERVAL '5 days')
ON CONFLICT DO NOTHING;
```

### PHẦN 6I: Dữ liệu Favorites (Bác sĩ yêu thích)

```sql
-- ============================================
-- 6I: FAVORITES (Bác sĩ yêu thích)
-- 🔒 Dữ liệu private, mỗi user chỉ thấy favorites của mình
-- ============================================

INSERT INTO favorites (patient_id, doctor_id) VALUES
-- An yêu thích BS. Đức và BS. Lan
('11111111-aaaa-aaaa-aaaa-111111111111', '44444444-bbbb-bbbb-bbbb-444444444444'),
('11111111-aaaa-aaaa-aaaa-111111111111', '77777777-bbbb-bbbb-bbbb-777777777777'),

-- Bích Ngọc yêu thích BS. Hương, BS. Nam, BS. Đức
('22222222-aaaa-aaaa-aaaa-222222222222', '55555555-bbbb-bbbb-bbbb-555555555555'),
('22222222-aaaa-aaaa-aaaa-222222222222', '88888888-bbbb-bbbb-bbbb-888888888888'),
('22222222-aaaa-aaaa-aaaa-222222222222', '44444444-bbbb-bbbb-bbbb-444444444444'),

-- Cường yêu thích BS. Đức
('33333333-aaaa-aaaa-aaaa-333333333333', '44444444-bbbb-bbbb-bbbb-444444444444')
ON CONFLICT (patient_id, doctor_id) DO NOTHING;
```

### PHẦN 6J: Dữ liệu Notifications (Thông báo)

```sql
-- ============================================
-- 6J: NOTIFICATIONS (Thông báo)
-- 🆕 MỚI THÊM (bảng này bị thiếu trong schema cũ)
-- 🔒 Dữ liệu private, mỗi user chỉ thấy thông báo của mình
-- ============================================

-- Thông báo cho An
INSERT INTO notifications (user_id, title, body, type, is_read, created_at) VALUES
('11111111-aaaa-aaaa-aaaa-111111111111',
 'Lịch hẹn đã xác nhận',
 'Lịch hẹn với BS. Ngô Thanh Lan vào 10:00 ngày ' || TO_CHAR(CURRENT_DATE + INTERVAL '3 days', 'DD/MM/YYYY') || ' đã được xác nhận.',
 'appointment', false, NOW() - INTERVAL '1 hour'),
('11111111-aaaa-aaaa-aaaa-111111111111',
 'Nhắc nhở uống thuốc',
 'Nhớ uống Aspirin 81mg sau ăn sáng và Atorvastatin 10mg buổi tối nhé!',
 'reminder', false, NOW() - INTERVAL '6 hours'),
('11111111-aaaa-aaaa-aaaa-111111111111',
 'Thanh toán thành công',
 'Thanh toán 350.000đ qua PayOS cho lịch hẹn với BS. Phạm Minh Đức thành công.',
 'payment', true, NOW() - INTERVAL '30 days'),
('11111111-aaaa-aaaa-aaaa-111111111111',
 'Khám hoàn tất',
 'Buổi khám da liễu với BS. Đặng Quốc Hùng đã hoàn tất. Hãy đánh giá trải nghiệm!',
 'appointment', true, NOW() - INTERVAL '15 days'),

-- Thông báo cho Bích Ngọc
('22222222-aaaa-aaaa-aaaa-222222222222',
 'Tin nhắn mới từ BS. Vũ Thị Hương',
 'BS. Hương: Nhớ đặt lịch trước nhé. Nếu bé sốt lại hoặc khó thở thì đưa đến ngay nha!',
 'chat', false, NOW() - INTERVAL '30 minutes'),
('22222222-aaaa-aaaa-aaaa-222222222222',
 'Nhắc nhở lịch tái khám',
 'Bạn có lịch tái khám Nhi khoa với BS. Vũ Thị Hương vào ' || TO_CHAR(CURRENT_DATE + INTERVAL '5 days', 'DD/MM/YYYY') || ' lúc 09:00.',
 'reminder', false, NOW() - INTERVAL '2 hours'),
('22222222-aaaa-aaaa-aaaa-222222222222',
 'Kết quả xét nghiệm',
 'Kết quả xét nghiệm máu của bạn tại BV Tai Mũi Họng đã có. Liên hệ BS. Hoàng Văn Nam để xem chi tiết.',
 'system', true, NOW() - INTERVAL '5 days'),

-- Thông báo cho Cường
('33333333-aaaa-aaaa-aaaa-333333333333',
 'Lịch hẹn đã huỷ',
 'Lịch hẹn tư vấn thần kinh với BS. Ngô Thanh Lan đã bị huỷ. Lý do: Bệnh nhân bận việc đột xuất.',
 'cancellation', true, NOW() - INTERVAL '5 days'),
('33333333-aaaa-aaaa-aaaa-333333333333',
 'Hoàn tiền thành công',
 'Hoàn tiền 320.000đ cho lịch hẹn đã huỷ với BS. Ngô Thanh Lan qua PayOS.',
 'payment', true, NOW() - INTERVAL '4 days'),
('33333333-aaaa-aaaa-aaaa-333333333333',
 'Nhắc nhở đo huyết áp',
 'Đừng quên đo huyết áp 2 lần/ngày và ghi sổ theo dõi. Tái khám BS. Phạm Minh Đức sau 1 tháng.',
 'reminder', false, NOW() - INTERVAL '3 hours'),

-- Thông báo cho bác sĩ BS. Đức
('44444444-bbbb-bbbb-bbbb-444444444444',
 'Bệnh nhân mới đặt lịch',
 'Bệnh nhân Nguyễn Văn An đặt lịch khám Tim mạch ngày ' || TO_CHAR(CURRENT_DATE - INTERVAL '30 days', 'DD/MM/YYYY'),
 'appointment', true, NOW() - INTERVAL '31 days'),
('44444444-bbbb-bbbb-bbbb-444444444444',
 'Đánh giá mới',
 'Lê Hoàng Cường đã đánh giá 4⭐ cho buổi khám ngày ' || TO_CHAR(CURRENT_DATE - INTERVAL '10 days', 'DD/MM/YYYY'),
 'review', false, NOW() - INTERVAL '9 days'),

-- Thông báo cho bác sĩ BS. Hương
('55555555-bbbb-bbbb-bbbb-555555555555',
 'Lịch hẹn mới chờ xác nhận',
 'Trần Thị Bích Ngọc đặt lịch tái khám Nhi khoa ngày ' || TO_CHAR(CURRENT_DATE + INTERVAL '5 days', 'DD/MM/YYYY') || ' lúc 09:00.',
 'appointment', false, NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;
```

---

## 📊 BẢNG THAM CHIẾU TÀI KHOẢN TEST

| Vai trò | Họ tên | Email | Mật khẩu | UUID |
|---------|--------|-------|-----------|------|
| 🏥 Bệnh nhân | Nguyễn Văn An | patient1@test.com | Test@123456 | `11111111-aaaa-...` |
| 🏥 Bệnh nhân | Trần Thị Bích Ngọc | patient2@test.com | Test@123456 | `22222222-aaaa-...` |
| 🏥 Bệnh nhân | Lê Hoàng Cường | patient3@test.com | Test@123456 | `33333333-aaaa-...` |
| 👨‍⚕️ Bác sĩ | BS. Phạm Minh Đức | doctor1@test.com | Test@123456 | `44444444-bbbb-...` |
| 👩‍⚕️ Bác sĩ | BS. Vũ Thị Hương | doctor2@test.com | Test@123456 | `55555555-bbbb-...` |
| 👨‍⚕️ Bác sĩ | BS. Đặng Quốc Hùng | doctor3@test.com | Test@123456 | `66666666-bbbb-...` |
| 👩‍⚕️ Bác sĩ | BS. Ngô Thanh Lan | doctor4@test.com | Test@123456 | `77777777-bbbb-...` |
| 👨‍⚕️ Bác sĩ | BS. Hoàng Văn Nam | doctor5@test.com | Test@123456 | `88888888-bbbb-...` |
| 🔧 Admin | Admin Hệ Thống | admin@test.com | Test@123456 | `99999999-cccc-...` |

---

## 📝 LỊCH SỬ THAY ĐỔI

| Ngày | Thay đổi | Phần cần chạy lại |
|------|----------|------------------|
| 2026-05-25 | Khởi tạo schema hoàn chỉnh | Tất cả (PHẦN 1-6) |
| 2026-05-25 | 🆕 Thêm bảng `notifications` (bị thiếu) | PHẦN 1, 2, 3 |
| 2026-05-25 | 🆕 Thêm trigger tự động tạo thông báo | PHẦN 4 |
| 2026-05-25 | 🆕 Thêm trigger `handle_new_user` | PHẦN 4 |
| 2026-05-25 | 🆕 Thêm dữ liệu mẫu tiếng Việt | PHẦN 6 |
