# 🚀 Hướng dẫn Deploy Doctor Booking App lên Vercel

> **Mục đích:** Học tập & Demo
> **Web:** Deploy lên Vercel (free)
> **App:** Build APK → cài trực tiếp trên điện thoại
> **Backend:** Supabase Cloud (đã có sẵn, không cần deploy)

---

## 📋 Tổng quan Vercel

| Tiêu chí | Chi tiết |
|----------|----------|
| **Website** | [vercel.com](https://vercel.com) |
| **Chi phí** | 🆓 Miễn phí (Hobby plan) |
| **Bandwidth** | 100GB / tháng |
| **Builds** | 6,000 phút / tháng |
| **SSL** | ✅ Tự động HTTPS |
| **Custom domain** | ✅ Miễn phí |
| **Preview URL** | ✅ Mỗi commit/PR tạo URL riêng |
| **CDN** | Edge Network toàn cầu, tốc độ cao |
| **Auto Deploy** | ✅ Push code lên Git → tự động deploy |

---

## 🔧 Thông tin cần chuẩn bị trước

### 1. Tài khoản cần có
- [ ] **Tài khoản GitHub** (hoặc GitLab/Bitbucket) — để lưu source code
- [ ] **Tài khoản Vercel** — đăng ký miễn phí tại [vercel.com/signup](https://vercel.com/signup) (đăng nhập bằng GitHub cho tiện)

### 2. Công cụ cần cài đặt
- [ ] **Flutter SDK** (đã có)
- [ ] **Node.js** (phiên bản 18+) — tải tại [nodejs.org](https://nodejs.org)
- [ ] **Git** — tải tại [git-scm.com](https://git-scm.com)

### 3. Thông tin API Keys (đã có trong file `.env`)

| Biến | Mô tả | Nơi lấy |
|------|--------|---------|
| `SUPABASE_URL` | URL của Supabase project | [supabase.com/dashboard](https://supabase.com/dashboard) → Settings → API |
| `SUPABASE_ANON_KEY` | Public anon key | Cùng trang trên |
| `AGORA_APP_ID` | App ID cho video call | [console.agora.io](https://console.agora.io) |
| `AGORA_CERTIFICATE` | Certificate cho Agora | Cùng trang trên |
| `PAYOS_CLIENT_ID` | Client ID thanh toán | [payos.vn](https://payos.vn) |
| `PAYOS_API_KEY` | API Key thanh toán | Cùng trang trên |
| `PAYOS_CHECKSUM_KEY` | Checksum key | Cùng trang trên |
| `FIREBASE_API_KEY` | Firebase Web API Key | [console.firebase.google.com](https://console.firebase.google.com) → Project Settings |
| `FIREBASE_AUTH_DOMAIN` | Firebase Auth domain | Cùng trang trên |
| `FIREBASE_PROJECT_ID` | Firebase Project ID | Cùng trang trên |
| `FIREBASE_STORAGE_BUCKET` | Storage bucket | Cùng trang trên |
| `FIREBASE_MESSAGING_SENDER_ID` | Sender ID | Cùng trang trên |
| `FIREBASE_APP_ID` | Firebase App ID | Cùng trang trên |
| `FIREBASE_MEASUREMENT_ID` | Google Analytics ID | Cùng trang trên |

---

## 📝 Các bước Deploy lên Vercel

### Bước 1: Build Flutter Web

```bash
# Di chuyển vào thư mục app
cd app

# Chạy script inject env + build (Linux/macOS)
./scripts/build_web.sh dev

# HOẶC build thủ công (Windows)
flutter build web --release --dart-define-from-file=.env.dev
```

> **Sau khi build xong**, output nằm ở thư mục `app/build/web/`

---

### Bước 2: Cấu hình SPA Redirect

Flutter Web là Single Page Application (SPA), cần file cấu hình để Vercel xử lý routing đúng.

**Tạo file `app/build/web/vercel.json`:**

```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

> Nếu không có file này, khi người dùng refresh trang hoặc truy cập URL trực tiếp sẽ bị lỗi 404.

---

### Bước 3: Deploy lên Vercel

#### Cách A: Deploy bằng CLI (nhanh nhất) ⭐

```bash
# 1. Cài Vercel CLI
npm install -g vercel

# 2. Đăng nhập (mở trình duyệt để xác thực)
vercel login

# 3. Deploy thư mục build
cd app/build/web
vercel

# Vercel sẽ hỏi vài câu:
#   ? Set up and deploy? → Y
#   ? Which scope? → Chọn tài khoản của bạn
#   ? Link to existing project? → N
#   ? What's your project's name? → doctor-booking (hoặc tên bạn muốn)
#   ? In which directory is your code located? → ./
#   ? Want to modify these settings? → N

# 4. Sau khi test OK, deploy production
vercel --prod
```

**Kết quả:** Vercel trả về URL dạng `https://doctor-booking-xxx.vercel.app`

---

#### Cách B: Deploy bằng GitHub (tự động) ⭐⭐

Cách này tiện hơn — mỗi lần push code lên GitHub, Vercel tự động build và deploy.

**Bước B.1: Push code lên GitHub**

```bash
# Tại thư mục gốc project
cd "c:\Users\LECOO\Desktop\New folder (2)"

# Khởi tạo Git (nếu chưa có)
git init
git add .
git commit -m "Initial commit"

# Tạo repo trên GitHub (github.com/new) rồi kết nối
git remote add origin https://github.com/YOUR_USERNAME/doctor-booking.git
git branch -M main
git push -u origin main
```

**Bước B.2: Kết nối Vercel với GitHub**

1. Truy cập [vercel.com/new](https://vercel.com/new)
2. Nhấn **"Import Git Repository"**
3. Chọn repo `doctor-booking` vừa push
4. Cấu hình build:

| Cài đặt | Giá trị |
|----------|---------|
| **Framework Preset** | `Other` |
| **Root Directory** | `app` |
| **Build Command** | `flutter build web --release --dart-define-from-file=.env.dev` |
| **Output Directory** | `build/web` |
| **Install Command** | _(để trống)_ |

5. **Environment Variables** — nhấn "Add" và thêm tất cả biến từ file `.env.dev`:

```
SUPABASE_URL = https://ynpzpxikzrxmbaokchei.supabase.co
SUPABASE_ANON_KEY = eyJhbGci...
AGORA_APP_ID = 64bf3c...
...
```

6. Nhấn **"Deploy"**

> ⚠️ **Lưu ý:** Vercel không có Flutter SDK sẵn. Nếu dùng Cách B, bạn cần thêm bước cài Flutter trong build command hoặc build local rồi push thư mục `build/web` lên một branch riêng.

---

#### Cách C: Deploy thủ công (đơn giản nhất) — Kéo thả

1. Build Flutter web ở local:
   ```bash
   cd app
   flutter build web --release --dart-define-from-file=.env.dev
   ```

2. Truy cập [vercel.com/new](https://vercel.com/new)

3. **Kéo thả** thư mục `app/build/web` vào trang web Vercel

4. Đợi vài giây → Vercel trả về URL!

> Đây là cách nhanh nhất cho mục đích demo/học tập.

---

### Bước 4: Cấu hình Custom Domain (tùy chọn)

Nếu bạn có domain riêng:

1. Vào **Vercel Dashboard** → chọn project
2. Vào **Settings** → **Domains**
3. Thêm domain (ví dụ: `doctorbooking.vn`)
4. Vercel hiện DNS records cần cấu hình:

```
Type: CNAME
Name: @
Value: cname.vercel-dns.com
```

5. Vào nhà cung cấp domain (Tenten, MatBao, GoDaddy...) → cập nhật DNS
6. Đợi 5-30 phút để DNS propagate → xong!

---

## 📱 Build APK cho điện thoại

Vì mục đích học tập, chỉ cần build APK và cài trực tiếp:

```bash
cd app

# Build APK
flutter build apk --release --dart-define-from-file=.env.dev

# File APK nằm ở:
# app/build/app/outputs/flutter-apk/app-release.apk
```

**Cách cài APK lên điện thoại:**
1. Copy file `app-release.apk` sang điện thoại (USB / Zalo / Google Drive)
2. Trên điện thoại: Bật **"Cho phép cài từ nguồn không xác định"** (Settings → Security)
3. Mở file APK → Cài đặt → Xong!

> APK sẽ tự kết nối đến Supabase Cloud qua internet. Không cần cấu hình thêm gì.

---

## 🔄 Quy trình cập nhật sau khi deploy

```
Sửa code → Build lại → Deploy lại
```

### Nếu dùng CLI:
```bash
cd app
flutter build web --release --dart-define-from-file=.env.dev
cd build/web
vercel --prod
```

### Nếu dùng GitHub:
```bash
git add .
git commit -m "Update feature X"
git push
# → Vercel tự động deploy!
```

---

## ❓ Xử lý lỗi thường gặp

### 1. Trắng trang sau khi deploy
**Nguyên nhân:** Base href sai
**Cách sửa:**
```bash
flutter build web --release --base-href="/" --dart-define-from-file=.env.dev
```

### 2. Refresh trang bị 404
**Nguyên nhân:** Thiếu SPA rewrite config
**Cách sửa:** Tạo file `vercel.json` trong `build/web/` (xem Bước 2)

### 3. API không hoạt động (CORS error)
**Nguyên nhân:** Supabase chặn domain mới
**Cách sửa:**
1. Vào [Supabase Dashboard](https://supabase.com/dashboard)
2. → **Authentication** → **URL Configuration**
3. Thêm URL Vercel vào **Redirect URLs**: `https://your-app.vercel.app/**`

### 4. Firebase Push Notification không hoạt động trên web
**Nguyên nhân:** Firebase chưa cho phép domain mới
**Cách sửa:**
1. Vào [Firebase Console](https://console.firebase.google.com)
2. → **Authentication** → **Settings** → **Authorized domains**
3. Thêm domain: `your-app.vercel.app`

### 5. Build APK lỗi "Key not found"
**Nguyên nhân:** File `.env.dev` không đúng đường dẫn
**Cách sửa:** Đảm bảo chạy lệnh từ thư mục `app/` và file `.env.dev` nằm trong `app/`

---

## 📊 Giới hạn Free Tier cần biết

| Service | Giới hạn Free | Đủ cho học tập? |
|---------|--------------|-----------------|
| **Vercel** | 100GB bandwidth, 6000 phút build/tháng | ✅ Dư sức |
| **Supabase** | 500MB DB, 1GB storage, 2GB bandwidth | ✅ Đủ dùng |
| **Agora** | 10,000 phút free/tháng | ✅ Rất nhiều |
| **Firebase** | 10GB storage, push unlimited | ✅ Dư |
| **PayOS** | Sandbox miễn phí | ✅ Test thoải mái |

---

## 🎯 Tóm tắt

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│   🌐 Web:  Vercel (free) — vercel.com                │
│   📱 App:  Build APK → cài trực tiếp                │
│   🗄️  DB:   Supabase Cloud (đã host sẵn)            │
│                                                      │
│   💰 Tổng chi phí: $0                                │
│                                                      │
│   Cách nhanh nhất:                                   │
│   1. flutter build web --dart-define-from-file=...   │
│   2. Kéo thả build/web lên vercel.com/new            │
│   3. Xong! ✅                                         │
│                                                      │
└──────────────────────────────────────────────────────┘
```
