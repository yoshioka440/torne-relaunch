#!/bin/bash
# torne再起動.app を組み立てる
#
# 使い方:
#   ./build.sh                 # ~/Applications にインストール
#   ./build.sh /Applications   # インストール先を指定
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="torne再起動"
DEST_DIR="${1:-$HOME/Applications}"
APP="$DEST_DIR/$APP_NAME.app"

mkdir -p "$DEST_DIR"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>$APP_NAME</string>
  <key>CFBundleDisplayName</key><string>$APP_NAME</string>
  <key>CFBundleIdentifier</key><string>io.github.torne-relaunch</string>
  <key>CFBundleVersion</key><string>1.0</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleExecutable</key><string>launch</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
EOF

cp scripts/launch "$APP/Contents/MacOS/launch"
chmod 755 "$APP/Contents/MacOS/launch"
cp assets/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

# Finder のアイコンキャッシュを更新
touch "$APP"

echo "Built: $APP"
