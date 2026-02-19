#!/bin/bash
#
# build-automator-app.sh — Build the Non App Store Apps Download Automator App
# ==============================================================================
#
# PURPOSE:
#   Compiles the AppleScript source into a native macOS .app bundle and
#   installs it to iCloud Drive for cross-Mac sync. Run this after editing
#   DownloadApps.applescript or apps.txt.
#
# WHAT IT DOES:
#   1. Removes any previous build of the .app bundle
#   2. Compiles DownloadApps.applescript into a universal .app (osacompile)
#   3. Bundles apps.txt into the app's Resources folder
#   4. Copies the built app to iCloud Drive > Automator (if available)
#
# USAGE:
#   bash build-automator-app.sh
#
# REQUIREMENTS:
#   - macOS (osacompile is included with Xcode Command Line Tools)
#   - iCloud Drive enabled (optional, for cross-Mac sync)
#

set -e

# ── Config ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Download Apps.app"
APP_BUNDLE="$SCRIPT_DIR/$APP_NAME"

echo "Building '$APP_NAME'..."

# ── Clean previous build ───────────────────────────────────────────────
rm -rf "$APP_BUNDLE"

# ── Compile AppleScript into .app ──────────────────────────────────────
osacompile -o "$APP_BUNDLE" "$SCRIPT_DIR/DownloadApps.applescript"

# ── Bundle the app list config ─────────────────────────────────────────
cp "$SCRIPT_DIR/apps.txt" "$APP_BUNDLE/Contents/Resources/apps.txt"

echo ""
echo "Done! '$APP_NAME' has been created."

# ── Install to iCloud (cross-Mac sync) ────────────────────────────────
ICLOUD_AUTOMATOR="$HOME/Library/Mobile Documents/com~apple~Automator/Documents"
if [ -d "$ICLOUD_AUTOMATOR" ]; then
    echo "Copying to iCloud Automator folder for cross-machine sync..."
    rm -rf "$ICLOUD_AUTOMATOR/$APP_NAME"
    cp -R "$APP_BUNDLE" "$ICLOUD_AUTOMATOR/$APP_NAME"
    echo ""
    echo "Installed to:"
    echo "  iCloud Drive > Automator > $APP_NAME"
    echo "  ($ICLOUD_AUTOMATOR/$APP_NAME)"
    echo ""
    echo "  This syncs automatically across all your Macs via iCloud."
    echo "  After a system reload, just open it from iCloud — your app list is ready."
else
    echo ""
    echo "  iCloud Automator folder not found. To enable cross-machine sync:"
    echo "  1. Make sure iCloud Drive is enabled in System Settings > Apple Account > iCloud"
    echo "  2. Manually copy '$APP_NAME' to iCloud Drive > Automator"
fi

# ── Usage instructions ─────────────────────────────────────────────────
echo ""
echo "  To run: double-click '$APP_NAME'"
echo "  To edit the app list:"
echo "    Right-click app → Show Package Contents → Contents → Resources → apps.txt"
