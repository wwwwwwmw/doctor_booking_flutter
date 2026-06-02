# 📋 CHỨC NĂNG NGHIỆP VỤ CHI TIẾT

## 1. Tổng Quan Phân Quyền

| Vai trò | Mô tả |
|---|---|
| **Patient (Bệnh nhân)** | Người dùng cuối, tìm kiếm và đặt lịch khám |
| **Doctor (Bác sĩ)** | Quản lý lịch trình, xem bệnh nhân, ghi chép y khoa |
| **Admin** | Quản trị hệ thống (phase 2 - web admin) |

---

## 2. Module Authentication (Xác thực)

### 2.1 Đăng ký
- [ ] Đăng ký bằng Email + Password
- [ ] Đăng ký bằng Google (OAuth)
- [ ] Chọn vai trò: Bệnh nhân / Bác sĩ
- [ ] Xác minh email (Supabase Auth auto)
- [ ] Nhập thông tin cá nhân sau đăng ký (onboarding profile)
- [ ] Bác sĩ: Upload giấy phép hành nghề → chờ duyệt

### 2.2 Đăng nhập
- [ ] Đăng nhập Email/Password
- [ ] Đăng nhập Google
- [ ] Remember me (auto login)
- [ ] Forgot Password (reset qua email)

### 2.3 Quản lý Session
- [ ] Auto refresh token (Supabase handles)
- [ ] Logout
- [ ] Multi-device token management

---

## 3. Module Patient (Bệnh nhân)

### 3.1 Trang Chủ (Home)
- [ ] Hiển thị lịch hẹn sắp tới (upcoming appointment card)
- [ ] Danh sách bác sĩ nổi bật / gần đây
- [ ] Danh mục chuyên khoa (horizontal scroll)
- [ ] Banner/Promotion carousel
- [ ] Quick search bar
- [ ] Notification badge

### 3.2 Tìm Kiếm Bác Sĩ (Search)
- [ ] Tìm theo tên bác sĩ
- [ ] Lọc theo chuyên khoa
- [ ] Lọc theo đánh giá (rating)
- [ ] Lọc theo giá tư vấn
- [ ] Lọc theo phòng khám/bệnh viện
- [ ] Sắp xếp: Rating cao nhất, Gần nhất, Phí thấp nhất
- [ ] Hiển thị dạng list/grid

### 3.3 Chi Tiết Bác Sĩ (Doctor Detail)
- [ ] Thông tin cá nhân (tên, ảnh, chuyên khoa)
- [ ] Tiểu sử / Mô tả (Bio)
- [ ] Số năm kinh nghiệm
- [ ] Phòng khám / Địa chỉ
- [ ] Phí tư vấn
- [ ] Rating trung bình + Số lượng review
- [ ] Danh sách reviews
- [ ] Lịch làm việc (available days/hours)
- [ ] Nút "Đặt lịch" (CTA)
- [ ] Nút "Yêu thích" (favorite)

### 3.4 Đặt Lịch Hẹn (Book Appointment)
- [ ] Chọn ngày (Calendar picker)
- [ ] Hiển thị time slots khả dụng (theo lịch bác sĩ)
- [ ] Slots đã đặt hiển thị disabled
- [ ] Chọn loại tư vấn: Trực tiếp / Video / Phone
- [ ] Thêm ghi chú cho bác sĩ (patient note)
- [ ] Xác nhận thông tin trước khi đặt
- [ ] Xác nhận đặt lịch thành công
- [ ] Tùy chọn thêm vào Calendar thiết bị
- [ ] Push notification cho bác sĩ khi có lịch mới

### 3.5 Quản Lý Lịch Hẹn (Appointments)
- [ ] Tab: Sắp tới (Upcoming)
- [ ] Tab: Đã hoàn thành (Completed)
- [ ] Tab: Đã hủy (Cancelled)
- [ ] Chi tiết lịch hẹn
- [ ] Hủy lịch hẹn (với lý do)
- [ ] Đổi lịch (Reschedule)
- [ ] Countdown timer cho lịch hẹn gần

### 3.6 Lịch (Calendar View)
- [ ] Hiển thị lịch tháng
- [ ] Đánh dấu ngày có lịch hẹn
- [ ] Xem chi tiết lịch hẹn từ calendar
- [ ] Đồng bộ với calendar thiết bị

### 3.7 Đánh Giá & Nhận Xét (Reviews)
- [ ] Đánh giá sau khi hoàn thành cuộc hẹn (1-5 sao)
- [ ] Viết nhận xét
- [ ] Xem lại đánh giá đã gửi
- [ ] Chỉnh sửa đánh giá (trong 24h)

### 3.8 Hồ Sơ Y Tế (Medical Records)
- [ ] Xem danh sách hồ sơ y tế
- [ ] Chi tiết: Chẩn đoán, Đơn thuốc, Ghi chú bác sĩ
- [ ] Tải xuống/Xem tệp đính kèm
- [ ] Lọc theo bác sĩ / ngày

### 3.9 Bác Sĩ Yêu Thích (Favorites)
- [ ] Danh sách bác sĩ yêu thích
- [ ] Thêm/Xóa yêu thích
- [ ] Truy cập nhanh để đặt lịch

### 3.10 Thông Báo (Notifications)
- [ ] Nhắc nhở lịch hẹn (trước 1 ngày, trước 1 giờ)
- [ ] Thông báo xác nhận đặt lịch
- [ ] Thông báo hủy lịch
- [ ] Thông báo từ bác sĩ
- [ ] Đánh dấu đã đọc / Xóa

### 3.11 Hồ Sơ Cá Nhân (Profile)
- [ ] Xem/Chỉnh sửa thông tin cá nhân
- [ ] Upload/Đổi ảnh đại diện
- [ ] Chỉnh sửa thông tin y tế (nhóm máu, dị ứng)
- [ ] Đổi mật khẩu
- [ ] Cài đặt thông báo
- [ ] Chuyển theme (Light/Dark)
- [ ] Chuyển ngôn ngữ (Vi/En)
- [ ] Đăng xuất
- [ ] Xóa tài khoản

---

## 4. Module Doctor (Bác sĩ)

### 4.1 Dashboard (Trang chủ)
- [ ] Thống kê nhanh: Tổng lịch hẹn hôm nay, tuần này
- [ ] Lịch hẹn tiếp theo (next appointment)
- [ ] Danh sách lịch hẹn hôm nay
- [ ] Biểu đồ thống kê (tuần/tháng)

### 4.2 Quản Lý Lịch Hẹn
- [ ] Danh sách lịch hẹn theo trạng thái
- [ ] Xác nhận / Từ chối lịch hẹn pending
- [ ] Hủy lịch hẹn (với lý do)
- [ ] Đánh dấu hoàn thành (completed)
- [ ] Đánh dấu vắng mặt (no-show)
- [ ] Xem ghi chú bệnh nhân
- [ ] Thêm ghi chú bác sĩ

### 4.3 Quản Lý Lịch Trình (Schedule)
- [ ] Thiết lập giờ làm việc theo ngày trong tuần
- [ ] Thiết lập thời lượng mỗi slot (15/30/45/60 phút)
- [ ] Thiết lập giờ nghỉ trưa
- [ ] Đánh dấu ngày nghỉ đột xuất
- [ ] Xem calendar tổng quan

### 4.4 Danh Sách Bệnh Nhân (Patients)
- [ ] Danh sách bệnh nhân đã khám
- [ ] Xem thông tin bệnh nhân
- [ ] Xem lịch sử khám của bệnh nhân
- [ ] Ghi chép hồ sơ y tế

### 4.5 Hồ Sơ Y Tế (Medical Records)
- [ ] Tạo hồ sơ y tế sau buổi khám
- [ ] Ghi chẩn đoán
- [ ] Ghi đơn thuốc
- [ ] Upload tệp đính kèm (hình ảnh, PDF)
- [ ] Xem lại hồ sơ đã tạo

### 4.6 Hồ Sơ Bác Sĩ (Profile)
- [ ] Chỉnh sửa thông tin cá nhân
- [ ] Chỉnh sửa bio/mô tả
- [ ] Cập nhật phí tư vấn
- [ ] Xem reviews từ bệnh nhân
- [ ] Cài đặt thông báo
- [ ] Đăng xuất

---

## 5. Module Hệ Thống (System)

### 5.1 Thông Báo Push (Push Notifications)
- [ ] Gửi notification khi đặt lịch mới
- [ ] Gửi notification khi hủy lịch
- [ ] Nhắc nhở trước lịch hẹn
- [ ] Notification khi có review mới (cho bác sĩ)
- [ ] Supabase Edge Function + FCM

### 5.2 Realtime Updates
- [ ] Realtime update lịch hẹn (Supabase Realtime)
- [ ] Realtime update notification count
- [ ] Realtime update trạng thái bác sĩ

### 5.3 Security
- [ ] Row Level Security (RLS) trên tất cả bảng
- [ ] JWT token validation
- [ ] Input validation
- [ ] Rate limiting (Supabase built-in)

---

## 6. Module Telemedicine (Khám Bệnh Từ Xa)

### 6.1 Video Call (Tư vấn qua Video)
- [ ] Giao diện video call toàn màn hình
- [ ] Bật/Tắt camera & microphone
- [ ] Chuyển camera trước/sau
- [ ] Hiển thị thời gian cuộc gọi
- [ ] Kết thúc cuộc gọi
- [ ] Chất lượng video tự điều chỉnh theo băng thông
- [ ] Reconnect tự động khi mất kết nối
- [ ] Gửi thông báo push khi bác sĩ/bệnh nhân bắt đầu cuộc gọi
- [ ] Hỗ trợ WebRTC (peer-to-peer) hoặc tích hợp Agora/Twilio SDK

### 6.2 Quản Lý Phiên Tư Vấn Từ Xa
- [ ] Chỉ cho phép video call khi appointment có `consultation_type = 'video'`
- [ ] Nút "Bắt đầu cuộc gọi" xuất hiện trước 5 phút giờ hẹn
- [ ] Phòng chờ (Waiting Room) cho bệnh nhân
- [ ] Bác sĩ chủ động bắt đầu/kết thúc phiên
- [ ] Ghi lại thời lượng cuộc gọi vào appointment record
- [ ] Đánh giá chất lượng cuộc gọi sau khi kết thúc

---

## 7. Module Chat In-App (Nhắn Tin Trực Tiếp)

### 7.1 Chat Giữa Bệnh Nhân & Bác Sĩ
- [ ] Giao diện chat realtime (Supabase Realtime)
- [ ] Gửi tin nhắn văn bản
- [ ] Gửi hình ảnh (chụp/chọn từ thư viện)
- [ ] Gửi tệp đính kèm (PDF kết quả xét nghiệm)
- [ ] Hiển thị trạng thái tin nhắn (đã gửi / đã nhận / đã đọc)
- [ ] Typing indicator (đang nhập...)
- [ ] Push notification khi có tin nhắn mới
- [ ] Hiển thị thời gian gửi tin nhắn
- [ ] Scroll to bottom khi có tin nhắn mới

### 7.2 Quản Lý Cuộc Trò Chuyện
- [ ] Danh sách các cuộc trò chuyện (inbox)
- [ ] Badge số tin nhắn chưa đọc
- [ ] Chat chỉ được tạo khi có appointment (confirmed/completed)
- [ ] Bác sĩ có thể đóng cuộc trò chuyện sau khi hoàn tất tư vấn
- [ ] Lịch sử chat được lưu trữ vĩnh viễn
- [ ] Tìm kiếm trong cuộc trò chuyện

---

## 8. Module Thanh Toán Điện Tử (Payment)

### 8.1 Cổng Thanh Toán Tích Hợp
- [ ] Thanh toán qua **MoMo** (QR Code / Ví MoMo)
- [ ] Thanh toán qua **VNPay** (ATM nội địa / Visa / Mastercard)
- [ ] Thanh toán qua **ZaloPay** (QR Code / Ví ZaloPay)
- [ ] Hiển thị tổng tiền phí tư vấn trước khi thanh toán
- [ ] Xác nhận thanh toán thành công → tự động xác nhận appointment

### 8.2 Quản Lý Thanh Toán
- [ ] Lịch sử thanh toán (transaction history)
- [ ] Chi tiết giao dịch (mã GD, thời gian, phương thức, số tiền)
- [ ] Trạng thái: Pending / Success / Failed / Refunded
- [ ] Hoàn tiền (Refund) khi hủy lịch trước 24h
- [ ] Xuất hóa đơn điện tử (PDF)
- [ ] Push notification xác nhận thanh toán

### 8.3 Thanh Toán Cho Bác Sĩ (Payout)
- [ ] Bác sĩ xem tổng doanh thu
- [ ] Lịch sử nhận thanh toán
- [ ] Rút tiền về tài khoản ngân hàng (yêu cầu Admin duyệt)

---

## 9. Module Quản Trị Hệ Thống (Admin Web Panel)

### 9.1 Dashboard Admin
- [ ] Tổng quan: Số bệnh nhân, bác sĩ, lịch hẹn, doanh thu
- [ ] Biểu đồ lịch hẹn theo ngày/tuần/tháng
- [ ] Biểu đồ doanh thu
- [ ] Danh sách lịch hẹn gần đây
- [ ] Cảnh báo hệ thống (tài khoản chờ duyệt, khiếu nại)

### 9.2 Quản Lý Tài Khoản Bác Sĩ
- [ ] Danh sách bác sĩ đăng ký (chờ duyệt / đã duyệt / từ chối)
- [ ] Xem chi tiết hồ sơ bác sĩ + giấy phép hành nghề
- [ ] **Duyệt / Từ chối** tài khoản bác sĩ
- [ ] Khóa / Mở khóa tài khoản bác sĩ
- [ ] Gửi thông báo cho bác sĩ

### 9.3 Quản Lý Bệnh Nhân
- [ ] Danh sách bệnh nhân
- [ ] Xem thông tin chi tiết
- [ ] Khóa / Mở khóa tài khoản
- [ ] Xem lịch sử hoạt động

### 9.4 Quản Lý Chuyên Khoa
- [ ] CRUD chuyên khoa (thêm/sửa/xóa)
- [ ] Upload icon chuyên khoa
- [ ] Quản lý tên đa ngôn ngữ (Vi/En)

### 9.5 Quản Lý Phòng Khám
- [ ] CRUD phòng khám
- [ ] Gán bác sĩ vào phòng khám
- [ ] Quản lý thông tin liên hệ

### 9.6 Quản Lý Lịch Hẹn (Admin)
- [ ] Xem tất cả lịch hẹn trong hệ thống
- [ ] Lọc theo trạng thái / bác sĩ / ngày
- [ ] Can thiệp hủy/chuyển lịch hẹn
- [ ] Xử lý khiếu nại

### 9.7 Quản Lý Đánh Giá (Reviews Moderation)
- [ ] Danh sách đánh giá
- [ ] Ẩn/Xóa đánh giá vi phạm
- [ ] Phản hồi đánh giá

### 9.8 Cài Đặt Hệ Thống
- [ ] Cấu hình phí nền tảng (platform fee %)
- [ ] Cấu hình thời gian hủy miễn phí
- [ ] Quản lý nội dung thông báo
- [ ] Cấu hình chính sách thanh toán

---

## 10. Module Analytics Dashboard (Thống Kê Cho Bác Sĩ)

### 10.1 Thống Kê Tổng Quan
- [ ] Tổng số bệnh nhân đã khám
- [ ] Tổng doanh thu (theo tuần/tháng/năm)
- [ ] Tỷ lệ hoàn thành lịch hẹn
- [ ] Rating trung bình theo thời gian
- [ ] Số lượng review mới

### 10.2 Biểu Đồ & Báo Cáo
- [ ] Biểu đồ cột: Lịch hẹn theo ngày trong tuần
- [ ] Biểu đồ tròn: Phân bố loại tư vấn (Trực tiếp / Video / Phone)
- [ ] Biểu đồ đường: Doanh thu theo tháng
- [ ] Biểu đồ: Tỷ lệ no-show
- [ ] Xuất báo cáo PDF/CSV

### 10.3 Insights
- [ ] Khung giờ được đặt nhiều nhất (peak hours)
- [ ] Bệnh nhân quay lại nhiều nhất (returning patients)
- [ ] So sánh với tháng trước

---

## 11. Phân Tích Hạn Chế Hiện Tại & Giải Pháp

| Hạn chế | Mức độ | Giải pháp |
|---|---|---|
| **Thiếu Admin Panel** — Không duyệt được tài khoản bác sĩ, không quản lý hệ thống | 🔴 Critical | Module 9: Admin Web Panel |
| **Thiếu Rating/Review minh bạch** — Chưa có cơ chế đánh giá bác sĩ | 🔴 Critical | Module 3.7 (Patient) + hiển thị trên Doctor Detail |
| **Thiếu Chat** — Không có kênh liên lạc giữa bệnh nhân và bác sĩ | 🟡 Medium | Module 7: Chat In-App |
| **Thiếu Medical Records** — Không quản lý hồ sơ y tế | 🟡 Medium | Module 3.8 (Patient) + 4.5 (Doctor) |
| **Thiếu thanh toán** — Không có cổng thanh toán tích hợp | 🟡 Medium | Module 8: Thanh Toán Điện Tử |
| **Chuyên khoa hardcoded** — Không thể thêm/sửa/xóa dynamic | 🟡 Medium | DB table `specialities` + Admin CRUD |
| **Chỉ 1 ngôn ngữ** — Không hỗ trợ đa ngôn ngữ | 🟢 Low | Flutter l10n (Vi/En) |
| **Cấu trúc dữ liệu cũ** — Appointments nhúng trong Patient/Doctor | 🔴 Critical | PostgreSQL tables riêng biệt (normalized) |
| **Thiếu Telemedicine** — Không hỗ trợ khám từ xa | 🟡 Medium | Module 6: Video Call + WebRTC |

---

## 12. Danh Sách Màn Hình (Screen List)

| # | Màn hình | Module | Ưu tiên |
|---|---|---|---|
| 1 | Splash Screen | Common | P0 |
| 2 | Onboarding (3 slides) | Common | P0 |
| 3 | Login Screen | Auth | P0 |
| 4 | Register Screen | Auth | P0 |
| 5 | Forgot Password | Auth | P1 |
| 6 | Patient Home | Patient | P0 |
| 7 | Doctor List / Search | Patient | P0 |
| 8 | Doctor Detail (+ Rating/Reviews) | Patient | P0 |
| 9 | Book Appointment (+ Payment) | Patient | P0 |
| 10 | Booking Confirmation | Patient | P0 |
| 11 | Upcoming Appointments | Patient | P0 |
| 12 | Appointment Detail | Patient | P0 |
| 13 | Calendar View | Patient | P1 |
| 14 | Patient Profile | Patient | P0 |
| 15 | Edit Profile | Patient | P1 |
| 16 | Favorites | Patient | P2 |
| 17 | Reviews (write/view) | Patient | P1 |
| 18 | Medical Records List | Patient | P1 |
| 19 | Medical Record Detail | Patient | P1 |
| 20 | Notifications | Patient | P1 |
| 21 | Chat Inbox | Chat | P1 |
| 22 | Chat Conversation | Chat | P1 |
| 23 | Video Call Screen | Telemedicine | P1 |
| 24 | Video Call Waiting Room | Telemedicine | P1 |
| 25 | Payment Checkout | Payment | P1 |
| 26 | Payment History | Payment | P1 |
| 27 | Transaction Detail | Payment | P1 |
| 28 | Doctor Dashboard (+ Analytics) | Doctor | P0 |
| 29 | Doctor Appointments | Doctor | P0 |
| 30 | Doctor Calendar | Doctor | P1 |
| 31 | Schedule Setup | Doctor | P0 |
| 32 | Patient List (Doctor) | Doctor | P1 |
| 33 | Doctor Profile | Doctor | P0 |
| 34 | Create Medical Record | Doctor | P1 |
| 35 | Doctor Analytics Dashboard | Doctor | P1 |
| 36 | Doctor Revenue Report | Doctor | P2 |
| 37 | Settings (Theme/Language) | Common | P1 |
| 38 | Admin Dashboard (Web) | Admin | P1 |
| 39 | Admin - Doctor Approval | Admin | P1 |
| 40 | Admin - User Management | Admin | P1 |
| 41 | Admin - Speciality Management | Admin | P1 |
| 42 | Admin - Appointment Overview | Admin | P2 |
| 43 | Admin - System Settings | Admin | P2 |

**Ưu tiên:** P0 = Bắt buộc MVP | P1 = Nên có | P2 = Có thể thêm sau

---

## 13. User Flow Chính

### Flow 1: Đặt Lịch Khám (Smart Booking)
```
Splash → Login → Patient Home → Tìm bác sĩ → Xem chi tiết (Rating/Reviews)
→ Chọn ngày + Real-time Slots → Chọn loại (Trực tiếp/Video/Phone)
→ Thêm ghi chú → Thanh toán (MoMo/VNPay/ZaloPay) → Xác nhận → Thành công
→ (Optional) Thêm vào Calendar
```

### Flow 2: Bác Sĩ Quản Lý
```
Login → Doctor Dashboard (Analytics) → Xem lịch hẹn hôm nay
→ Xác nhận/Từ chối → Hoàn thành buổi khám → Tạo hồ sơ y tế
→ Xem thống kê doanh thu
```

### Flow 3: Hủy Lịch (Bệnh nhân)
```
Patient Home → Upcoming Appointments → Appointment Detail
→ Hủy → Nhập lý do → Xác nhận → Hoàn tiền (nếu đủ điều kiện)
→ Notification cho bác sĩ
```

### Flow 4: Khám Bệnh Từ Xa (Telemedicine)
```
Appointment Detail (video type) → Waiting Room → Bác sĩ bắt đầu cuộc gọi
→ Video Call (bật/tắt cam, mic) → Kết thúc → Đánh giá chất lượng
→ Bác sĩ tạo hồ sơ y tế → Bệnh nhân xem kết quả
```

### Flow 5: Chat In-App
```
Appointment Detail → Mở Chat → Gửi tin nhắn / hình ảnh / tệp
→ Bác sĩ phản hồi (realtime) → Đóng cuộc trò chuyện khi hoàn tất
```

### Flow 6: Thanh Toán
```
Book Appointment → Chọn phương thức thanh toán (MoMo/VNPay/ZaloPay)
→ Redirect sang app thanh toán → Xác nhận → Callback → Cập nhật trạng thái
→ Nhận hóa đơn điện tử
```

### Flow 7: Admin Duyệt Bác Sĩ
```
Admin Login (Web) → Dashboard → Danh sách chờ duyệt
→ Xem hồ sơ + Giấy phép hành nghề → Duyệt/Từ chối
→ Notification cho bác sĩ
```

### Flow 8: Đánh Giá Bác Sĩ (Rating & Review)
```
Appointment hoàn thành → Notification đánh giá → Chọn sao (1-5)
→ Viết nhận xét → Gửi → Cập nhật rating trung bình bác sĩ
→ Hiển thị trên Doctor Detail
```
