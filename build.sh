#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_BUNDLE="$SCRIPT_DIR/DownloadApps.app"

echo "Building DownloadApps.app..."

# Create .app bundle structure
mkdir -p "$APP_BUNDLE/Contents/MacOS"

# Write Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>DownloadApps</string>
    <key>CFBundleIdentifier</key>
    <string>com.codecraftedapps.downloadapps</string>
    <key>CFBundleName</key>
    <string>Download Apps</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Compile Swift source
swiftc -framework SwiftUI -framework AppKit -O \
    -o "$APP_BUNDLE/Contents/MacOS/DownloadApps" \
    "$SCRIPT_DIR/DownloadApps.swift"

echo "Done! Open DownloadApps.app to start downloading."
