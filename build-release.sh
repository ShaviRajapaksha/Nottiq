#!/bin/bash
set -euo pipefail

APP_NAME="Nottiq"
BUNDLE_ID="com.nottiq"
VERSION="1.0.0"
BUILD_DIR=".build/release"
APP_BUNDLE="dist/${APP_NAME}.app"
DMG_NAME="dist/${APP_NAME}.dmg"
DMG_TMP="dist/${APP_NAME}.tmp.dmg"
VOLUME_NAME="${APP_NAME} ${VERSION}"

echo "→ Cleaning previous build"
rm -rf dist
mkdir -p dist

echo "→ Building release binary"
swift build -c release

echo "→ Assembling .app bundle"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

cp "AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"

cat > "${APP_BUNDLE}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "→ Creating DMG"
hdiutil create \
    -volname "${VOLUME_NAME}" \
    -srcfolder "${APP_BUNDLE}" \
    -ov \
    -format UDRW \
    "${DMG_TMP}"

MOUNT_DIR=$(hdiutil attach "${DMG_TMP}" | tail -1 | awk '{print $3}')

# Add Applications shortcut
ln -s /Applications "${MOUNT_DIR}/Applications"

# Add background image
mkdir -p "${MOUNT_DIR}/.background"
cp "dmg-background.png" "${MOUNT_DIR}/.background/background.png"

# Configure Finder window via AppleScript
osascript <<APPLESCRIPT
tell application "Finder"
    tell disk "${VOLUME_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 700, 500}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 128
        set background picture of viewOptions to file ".background:background.png"
        set position of item "${APP_NAME}.app" of container window to {160, 220}
        set position of item "Applications" of container window to {440, 220}
        close
        open
        update without registering applications
        delay 1
        close
    end tell
end tell
APPLESCRIPT

# Set .background folder invisible
SetFile -a V "${MOUNT_DIR}/.background" 2>/dev/null || true

sync
hdiutil detach "${MOUNT_DIR}"

echo "→ Compressing DMG"
hdiutil convert "${DMG_TMP}" -format UDZO -imagekey zlib-level=9 -o "${DMG_NAME}"
rm -f "${DMG_TMP}"