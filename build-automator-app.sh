#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Download Apps.app"
APP_BUNDLE="$SCRIPT_DIR/$APP_NAME"

echo "Building '$APP_NAME'..."

# Clean previous build
rm -rf "$APP_BUNDLE"

# Compile the AppleScript into a native .app (universal binary — Apple Silicon + Intel)
osacompile -o "$APP_BUNDLE" "$SCRIPT_DIR/DownloadApps.applescript"

# Bundle the editable app list config
cp "$SCRIPT_DIR/apps.txt" "$APP_BUNDLE/Contents/Resources/apps.txt"

echo ""
echo "Done! '$APP_NAME' has been created."
echo ""
echo "  Double-click to run it."
echo "  To edit the app list:"
echo "    Right-click app → Show Package Contents → Contents → Resources → apps.txt"
