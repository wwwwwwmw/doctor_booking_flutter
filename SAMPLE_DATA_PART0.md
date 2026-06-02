# 📦 DỮ LIỆU MẪU - PHẦN 0: Tạo Auth Users (CHẠY TRƯỚC PART 1)

> ⚠️ **QUAN TRỌNG:** Chạy file này TRƯỚC TIÊN, trước cả Part 1.
> Paste vào Supabase SQL Editor → Run
>
> **Mật khẩu test:**
> - Admin: `admin123`
> - Doctor: `doctor123`
> - Patient: `patient123`

```sql
-- ============================================
-- BƯỚC 0: Đảm bảo extension pgcrypto
-- ============================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================
-- XÓA DỮ LIỆU CŨ NẾU CÓ (tuần tự theo FK)
-- ============================================
DELETE FROM video_call_sessions WHERE true;
DELETE FROM chat_messages WHERE true;
DELETE FROM chat_conversations WHERE true;
DELETE FROM payments WHERE true;
DELETE FROM medical_records WHERE true;
DELETE FROM favorites WHERE true;
DELETE FROM reviews WHERE true;
DELETE FROM appointments WHERE true;
DELETE FROM doctors WHERE true;
DELETE FROM users WHERE true;

-- ============================================
-- TẠO AUTH USERS (bảng auth.users của Supabase)
-- Mật khẩu được hash bằng bcrypt
-- ============================================

-- Admin: admin123
INSERT INTO auth.users (
  id, instance_id, email, encrypted_password, email_confirmed_at,
  aud, role, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token
) VALUES
('a1000001-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000',
 'admin@doctorbooking.vn', crypt('admin123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Quản Trị Viên","role":"admin"}',
 NOW(), NOW(), '', '');

-- Doctor 1: doctor123
INSERT INTO auth.users (
  id, instance_id, email, encrypted_password, email_confirmed_at,
  aud, role, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token
) VALUES
('d2000001-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000',
 'bs.minhquan@gmail.com', crypt('doctor123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Nguyễn Minh Quân","role":"doctor"}',
 NOW(), NOW(), '', ''),
('d2000001-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000',
 'bs.thuha@gmail.com', crypt('doctor123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Trần Thu Hà","role":"doctor"}',
 NOW(), NOW(), '', ''),
('d2000001-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000',
 'bs.quanghuy@gmail.com', crypt('doctor123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Lê Quang Huy","role":"doctor"}',
 NOW(), NOW(), '', ''),
('d2000001-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000',
 'bs.maitrang@gmail.com', crypt('doctor123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Phạm Mai Trang","role":"doctor"}',
 NOW(), NOW(), '', ''),
('d2000001-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000',
 'bs.ducmanh@gmail.com', crypt('doctor123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Hoàng Đức Mạnh","role":"doctor"}',
 NOW(), NOW(), '', ''),
('d2000001-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000000',
 'bs.thuylinh@gmail.com', crypt('doctor123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Võ Thùy Linh","role":"doctor"}',
 NOW(), NOW(), '', ''),
('d2000001-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000000',
 'bs.tiendat@gmail.com', crypt('doctor123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Đặng Tiến Đạt","role":"doctor"}',
 NOW(), NOW(), '', ''),
('d2000001-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000000',
 'bs.ngoclan@gmail.com', crypt('doctor123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Bùi Ngọc Lan","role":"doctor"}',
 NOW(), NOW(), '', '');

-- Patients: patient123
INSERT INTO auth.users (
  id, instance_id, email, encrypted_password, email_confirmed_at,
  aud, role, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token
) VALUES
('b3000001-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000',
 'vana.nguyen@gmail.com', crypt('patient123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Nguyễn Văn An","role":"patient"}',
 NOW(), NOW(), '', ''),
('b3000001-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000',
 'thib.tran@gmail.com', crypt('patient123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Trần Thị Bích","role":"patient"}',
 NOW(), NOW(), '', ''),
('b3000001-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000',
 'vanc.le@gmail.com', crypt('patient123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Lê Văn Cường","role":"patient"}',
 NOW(), NOW(), '', ''),
('b3000001-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000',
 'thid.pham@gmail.com', crypt('patient123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Phạm Thị Dung","role":"patient"}',
 NOW(), NOW(), '', ''),
('b3000001-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000',
 'vane.hoang@gmail.com', crypt('patient123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Hoàng Văn Em","role":"patient"}',
 NOW(), NOW(), '', ''),
('b3000001-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000000',
 'thif.vo@gmail.com', crypt('patient123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Võ Thị Phương","role":"patient"}',
 NOW(), NOW(), '', ''),
('b3000001-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000000',
 'vang.dang@gmail.com', crypt('patient123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Đặng Văn Giang","role":"patient"}',
 NOW(), NOW(), '', ''),
('b3000001-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000000',
 'thih.bui@gmail.com', crypt('patient123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Bùi Thị Hồng","role":"patient"}',
 NOW(), NOW(), '', ''),
('b3000001-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000000',
 'vani.ngo@gmail.com', crypt('patient123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Ngô Văn Ích","role":"patient"}',
 NOW(), NOW(), '', ''),
('b3000001-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000000',
 'thik.ly@gmail.com', crypt('patient123', gen_salt('bf')),
 NOW(), 'authenticated', 'authenticated',
 '{"provider":"email","providers":["email"]}',
 '{"full_name":"Lý Thị Kim","role":"patient"}',
 NOW(), NOW(), '', '');

-- ============================================
-- TẠO IDENTITY CHO MỖI USER (bắt buộc cho Supabase Auth)
-- ============================================
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
SELECT
  id, id,
  json_build_object('sub', id, 'email', email, 'email_verified', true)::jsonb,
  'email', id::text, NOW(), NOW(), NOW()
FROM auth.users
WHERE id IN (
  'a1000001-0000-0000-0000-000000000001',
  'd2000001-0000-0000-0000-000000000001','d2000001-0000-0000-0000-000000000002',
  'd2000001-0000-0000-0000-000000000003','d2000001-0000-0000-0000-000000000004',
  'd2000001-0000-0000-0000-000000000005','d2000001-0000-0000-0000-000000000006',
  'd2000001-0000-0000-0000-000000000007','d2000001-0000-0000-0000-000000000008',
  'b3000001-0000-0000-0000-000000000001','b3000001-0000-0000-0000-000000000002',
  'b3000001-0000-0000-0000-000000000003','b3000001-0000-0000-0000-000000000004',
  'b3000001-0000-0000-0000-000000000005','b3000001-0000-0000-0000-000000000006',
  'b3000001-0000-0000-0000-000000000007','b3000001-0000-0000-0000-000000000008',
  'b3000001-0000-0000-0000-000000000009','b3000001-0000-0000-0000-000000000010'
);
```

## Thứ tự chạy

1. **SAMPLE_DATA_PART0.md** (file này) → Tạo auth users + mật khẩu
2. **SAMPLE_DATA_PART1.md** → Tạo profiles, doctors, appointments
3. **SAMPLE_DATA_PART2.md** → Tạo reviews, records, chat, payments

## Tài khoản test

| Role | Email | Mật khẩu |
|------|-------|-----------|
| Admin | admin@doctorbooking.vn | admin123 |
| Doctor | bs.minhquan@gmail.com | doctor123 |
| Doctor | bs.thuha@gmail.com | doctor123 |
| Patient | vana.nguyen@gmail.com | patient123 |
| Patient | thib.tran@gmail.com | patient123 |
