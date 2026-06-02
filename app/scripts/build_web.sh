#!/bin/bash
# ============================================
# Build script - Inject .env variables vào web files
# ============================================
# Sử dụng: ./scripts/build_web.sh [dev|staging|prod]
#
# Script này:
# 1. Đọc file .env tương ứng
# 2. Thay thế __PLACEHOLDER__ trong index.html và service worker
# 3. Build Flutter web với --dart-define-from-file

set -e

ENV=${1:-dev}
ENV_FILE=".env.${ENV}"

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Không tìm thấy file $ENV_FILE"
  echo "   Hãy copy .env.example thành $ENV_FILE và điền giá trị."
  exit 1
fi

echo "🚀 Building for environment: $ENV"
echo "📄 Using env file: $ENV_FILE"

# Đọc biến từ .env file
export $(grep -v '^#' "$ENV_FILE" | grep -v '^\s*$' | xargs)

# Thay thế placeholder trong index.html
echo "🔧 Injecting Firebase config into web/index.html..."
sed -i.bak \
  -e "s|__FIREBASE_API_KEY__|${FIREBASE_API_KEY}|g" \
  -e "s|__FIREBASE_AUTH_DOMAIN__|${FIREBASE_AUTH_DOMAIN}|g" \
  -e "s|__FIREBASE_PROJECT_ID__|${FIREBASE_PROJECT_ID}|g" \
  -e "s|__FIREBASE_STORAGE_BUCKET__|${FIREBASE_STORAGE_BUCKET}|g" \
  -e "s|__FIREBASE_MESSAGING_SENDER_ID__|${FIREBASE_MESSAGING_SENDER_ID}|g" \
  -e "s|__FIREBASE_APP_ID__|${FIREBASE_APP_ID}|g" \
  -e "s|__FIREBASE_MEASUREMENT_ID__|${FIREBASE_MEASUREMENT_ID}|g" \
  web/index.html

# Thay thế placeholder trong service worker
echo "🔧 Injecting Firebase config into web/firebase-messaging-sw.js..."
sed -i.bak \
  -e "s|__FIREBASE_API_KEY__|${FIREBASE_API_KEY}|g" \
  -e "s|__FIREBASE_AUTH_DOMAIN__|${FIREBASE_AUTH_DOMAIN}|g" \
  -e "s|__FIREBASE_PROJECT_ID__|${FIREBASE_PROJECT_ID}|g" \
  -e "s|__FIREBASE_STORAGE_BUCKET__|${FIREBASE_STORAGE_BUCKET}|g" \
  -e "s|__FIREBASE_MESSAGING_SENDER_ID__|${FIREBASE_MESSAGING_SENDER_ID}|g" \
  -e "s|__FIREBASE_APP_ID__|${FIREBASE_APP_ID}|g" \
  -e "s|__FIREBASE_MEASUREMENT_ID__|${FIREBASE_MEASUREMENT_ID}|g" \
  web/firebase-messaging-sw.js

# Build Flutter web
echo "🏗️  Building Flutter web..."
flutter build web --dart-define-from-file="$ENV_FILE" --release

# Khôi phục file gốc (để placeholder vẫn còn cho lần build sau)
echo "🔄 Restoring template files..."
mv web/index.html.bak web/index.html
mv web/firebase-messaging-sw.js.bak web/firebase-messaging-sw.js

echo "✅ Build hoàn tất! Output: build/web/"
