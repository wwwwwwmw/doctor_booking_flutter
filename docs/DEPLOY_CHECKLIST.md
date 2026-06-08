# 📋 Checklist Deploy - Doctor Booking App

> Tài liệu này liệt kê tất cả các bước cần kiểm tra và thực hiện khi chuyển từ local sang production.

---

## 1. Supabase Edge Functions

### 1.1 `admin-update-user` ⚠️ BẮT BUỘC
- **Mục đích**: Cho phép Admin đổi email + mật khẩu của user
- **File**: `supabase/functions/admin-update-user/index.ts`
- **Shared**: `supabase/functions/_shared/cors.ts`

**Deploy:**
```bash
supabase functions deploy admin-update-user
```

**Kiểm tra sau deploy:**
- [ ] Function xuất hiện trong Supabase Dashboard → Edge Functions
- [ ] Vào Admin → Người dùng → Chỉnh sửa → Đổi email → Lưu → Thành công
- [ ] Vào Admin → Người dùng → Chỉnh sửa → Đổi mật khẩu → Lưu → Thành công
- [ ] User bị đổi email/mật khẩu vẫn đăng nhập được với thông tin mới
- [ ] Nếu không phải admin gọi function → trả về lỗi 403

**Lưu ý:**
- Function dùng `SUPABASE_SERVICE_ROLE_KEY` (tự có sẵn trong Edge Function environment)
- KHÔNG cần cấu hình thêm env vars - Supabase tự inject `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`

---

### 1.2 `create-payos-payment` ⚠️ NẾU DÙNG PAYOS
- **Mục đích**: Tạo link thanh toán PayOS cho bệnh nhân
- **Được gọi từ**: `payment_repository.dart` → `initiatePayosPayment()`

**Cần cấu hình env:**
```bash
supabase secrets set PAYOS_CLIENT_ID=xxx
supabase secrets set PAYOS_API_KEY=xxx
supabase secrets set PAYOS_CHECKSUM_KEY=xxx
```

**Kiểm tra:**
- [ ] Đặt lịch hẹn → Thanh toán PayOS → Redirect đến trang PayOS
- [ ] Thanh toán xong → Quay lại app → Trạng thái = success

---

### 1.3 `check-payos-status` ⚠️ NẾU DÙNG PAYOS
- **Mục đích**: Kiểm tra trạng thái thanh toán PayOS
- **Được gọi từ**: `payment_repository.dart` → `checkPayosPaymentStatus()`

**Kiểm tra:**
- [ ] Sau khi thanh toán, gọi kiểm tra trạng thái trả về PAID/CANCELLED

---

## 2. Supabase Database (RLS Policies)

### 2.1 Kiểm tra Row Level Security
- [ ] Bảng `users`: RLS bật, policy cho phép user đọc profile mình, admin đọc tất cả
- [ ] Bảng `doctors`: RLS bật, cho phép public đọc (is_verified = true), admin sửa tất cả
- [ ] Bảng `appointments`: RLS bật, patient đọc của mình, doctor đọc lịch mình
- [ ] Bảng `payments`: RLS bật, patient đọc payment mình
- [ ] Bảng `reviews`: RLS bật, public đọc, patient insert
- [ ] Bảng `specialities`: RLS bật, public đọc

### 2.2 Admin cần có quyền đặc biệt
```sql
-- Ví dụ policy cho admin đọc tất cả users
CREATE POLICY "Admin can read all users" ON users
  FOR SELECT USING (
    auth.uid() IN (SELECT id FROM users WHERE role = 'admin')
  );

-- Admin có thể update tất cả users  
CREATE POLICY "Admin can update all users" ON users
  FOR UPDATE USING (
    auth.uid() IN (SELECT id FROM users WHERE role = 'admin')
  );
```

- [ ] Admin đọc được danh sách tất cả users
- [ ] Admin đọc được danh sách doctors (kể cả chưa verified)
- [ ] Admin duyệt/từ chối bác sĩ (update doctors + users)
- [ ] Admin khóa/mở khóa tài khoản (update users.is_active)
- [ ] Admin xóa user (delete users)

---

## 3. Luồng đăng ký bác sĩ

### 3.1 Kiểm tra luồng
- [ ] Đăng ký với role = doctor → `users.is_active = false`
- [ ] Đăng ký → tạo record trong bảng `doctors` (is_verified = false)
- [ ] Doctor đăng nhập khi chưa duyệt → Hiện màn hình "Chờ duyệt"
- [ ] Admin duyệt → `doctors.is_verified = true` + `users.is_active = true`
- [ ] Doctor đăng nhập sau khi duyệt → Vào DoctorHomeScreen bình thường
- [ ] Admin từ chối → Xóa record doctors + giữ user (is_active = false)

---

## 4. Biến môi trường (.env)

### 4.1 File `.env` cần có
```
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
```

- [ ] `.env` KHÔNG được commit vào git (đã có trong .gitignore)
- [ ] `.env.example` có sẵn mẫu để team copy

---

## 5. Build & Deploy App

### 5.1 Android
```bash
flutter build apk --release
# hoặc
flutter build appbundle --release
```
- [ ] Build thành công không lỗi
- [ ] App chạy đúng với Supabase production

### 5.2 iOS
```bash
flutter build ios --release
```
- [ ] Xcode archive thành công
- [ ] TestFlight upload OK

### 5.3 Web
```bash
flutter build web --release
```
- [ ] Deploy lên hosting (Firebase Hosting, Vercel, Netlify...)
- [ ] CORS headers đúng cho Edge Functions

---

## 6. Kiểm tra cuối cùng (Smoke Test)

### Bệnh nhân
- [ ] Đăng ký → Đăng nhập → Xem danh sách bác sĩ
- [ ] Đặt lịch hẹn → Thanh toán → Xem lịch sử
- [ ] Đánh giá bác sĩ → Review xuất hiện

### Bác sĩ
- [ ] Đăng ký → Hiện "Chờ duyệt" → Admin duyệt → Đăng nhập OK
- [ ] Xem lịch hẹn → Xác nhận/Từ chối
- [ ] Xem profile → Stats hiển thị đúng từ DB

### Admin
- [ ] Đăng nhập → Vào AdminDashboardScreen (không phải PatientHome)
- [ ] Dashboard: Stats đúng, biểu đồ hiển thị
- [ ] Quản lý người dùng: Tìm, lọc, sửa, khóa, xóa
- [ ] Duyệt bác sĩ: Duyệt/Từ chối hoạt động
- [ ] Đổi email/mật khẩu user (cần Edge Function đã deploy)
