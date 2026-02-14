#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Download Apps.app"
APP_BUNDLE="$SCRIPT_DIR/$APP_NAME"

echo "Building '$APP_NAME'..."

# Clean previous build
rm -rf "$APP_BUNDLE"

# Create .app bundle structure
mkdir -p "$APP_BUNDLE/Contents/MacOS"

# Symlink to Automator Application Stub
ln -s "/System/Library/Automator/Application Stub.app/Contents/MacOS/Application Stub" \
    "$APP_BUNDLE/Contents/MacOS/Application Stub"

# Write Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleAllowMixedLocalizations</key>
	<true/>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>Application Stub</string>
	<key>CFBundleIconFile</key>
	<string>AutomatorApplet</string>
	<key>CFBundleIdentifier</key>
	<string>com.codecraftedapps.download-apps</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>Download Apps</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>12.0</string>
	<key>LSUIElement</key>
	<true/>
	<key>NSMainNibFile</key>
	<string>ApplicationStub</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>
PLIST

# Write document.wflow (the Automator workflow definition)
cat > "$APP_BUNDLE/Contents/document.wflow" << 'WFLOW'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>523</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<integer>2</integer>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<true/>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>2.0.3</string>
				<key>AMApplication</key>
				<array>
					<string>Automator</string>
				</array>
				<key>AMBundleIdentifier</key>
				<string>com.apple.RunShellScript</string>
				<key>AMCategory</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>AMIconName</key>
				<string>RunShellScript</string>
				<key>AMKeyword</key>
				<string>shell script</string>
				<key>AMName</key>
				<string>Run Shell Script</string>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>AMRequiredResources</key>
				<array/>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run Shell Script.action</string>
				<key>ActionName</key>
				<string>Run Shell Script</string>
				<key>ActionParameters</key>
				<dict>
					<key>COMMAND_STRING</key>
					<string>#!/bin/bash
# ============================================================
#  NON APP STORE APPS DOWNLOAD
# ============================================================
#  Edit this list to add or remove apps!
#  Each "download" line follows this format:
#     download "App Name" "Direct Download URL" "FileName.dmg"
#
#  Files are saved to your Desktop.
# ============================================================

DEST="$HOME/Desktop"
ERRORS=0
SUCCESSES=0
TOTAL=0

download() {
    local name="$1" url="$2" file="$3"
    TOTAL=$((TOTAL + 1))
    echo "Downloading $name..."
    if curl -L -s -o "$DEST/$file" "$url"; then
        SUCCESSES=$((SUCCESSES + 1))
    else
        ERRORS=$((ERRORS + 1))
    fi
}

# ============================================================
#  APP LIST — Edit below to customize your downloads
# ============================================================

# Bambu Studio (latest release from GitHub)
BAMBU_URL=$(curl -s https://api.github.com/repos/bambulab/BambuStudio/releases/latest \
    | grep "browser_download_url.*mac.*\.dmg" \
    | head -1 \
    | cut -d '"' -f 4)
download "Bambu Studio" "$BAMBU_URL" "BambuStudio.dmg"

# Brave Browser
download "Brave Browser" \
    "https://referrals.brave.com/latest/Brave-Browser-arm64.dmg" \
    "BraveBrowser.dmg"

# Google Chrome
download "Google Chrome" \
    "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg" \
    "GoogleChrome.dmg"

# ChatGPT Desktop
download "ChatGPT" \
    "https://persistent.oaistatic.com/sidekick/public/ChatGPT_Desktop_public_latest.dmg" \
    "ChatGPT.dmg"

# Grammarly Desktop
download "Grammarly Desktop" \
    "https://download-mac.grammarly.com/Grammarly.dmg" \
    "Grammarly.dmg"

# Visual Studio Code (Apple Silicon)
download "Visual Studio Code" \
    "https://update.code.visualstudio.com/latest/darwin-arm64/stable" \
    "VSCode-arm64.zip"

# ============================================================
#  END OF APP LIST
# ============================================================

# Show completion dialog
if [ $ERRORS -eq 0 ]; then
    osascript -e "
        set result to button returned of (display dialog \"All $SUCCESSES apps downloaded successfully to your Desktop.\" &amp; return &amp; return &amp; \"Open the .dmg files to install, or unzip the .zip files to get the .app.\" buttons {\"Open Desktop\", \"Done\"} default button \"Done\" with title \"Download Apps\" with icon note)
        if result is \"Open Desktop\" then
            tell application \"Finder\" to open folder \"Desktop\" of home
        end if
    "
else
    osascript -e "
        display dialog \"Downloads finished.\" &amp; return &amp; return &amp; \"$SUCCESSES of $TOTAL succeeded.\" &amp; return &amp; \"$ERRORS failed — check your internet connection and try again.\" buttons {\"Open Desktop\", \"Done\"} default button \"Done\" with title \"Download Apps\" with icon caution
    "
fi</string>
					<key>CheckedForUserDefaultShell</key>
					<true/>
					<key>inputMethod</key>
					<integer>1</integer>
					<key>shell</key>
					<string>/bin/bash</string>
					<key>source</key>
					<string></string>
				</dict>
				<key>BundleIdentifier</key>
				<string>com.apple.RunShellScript</string>
				<key>CFBundleVersion</key>
				<string>2.0.3</string>
				<key>CanShowSelectedItemsWhenRun</key>
				<false/>
				<key>CanShowWhenRun</key>
				<true/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunShellScriptAction</string>
				<key>InputUUID</key>
				<string>A1B2C3D4-E5F6-7890-ABCD-EF1234567890</string>
				<key>Keywords</key>
				<array>
					<string>Shell</string>
					<string>Script</string>
				</array>
				<key>OutputUUID</key>
				<string>B2C3D4E5-F6A7-8901-BCDE-F12345678901</string>
				<key>UUID</key>
				<string>C3D4E5F6-A7B8-9012-CDEF-123456789012</string>
				<key>UnlocalizedApplications</key>
				<array>
					<string>Automator</string>
				</array>
			</dict>
		</dict>
	</array>
	<key>connectors</key>
	<dict/>
	<key>workflowMetaData</key>
	<dict>
		<key>workflowTypeIdentifier</key>
		<string>com.apple.Automator.application</string>
	</dict>
</dict>
</plist>
WFLOW

echo ""
echo "Done! '$APP_NAME' has been created."
echo ""
echo "  Double-click to run it."
echo "  Right-click → Open With → Automator to edit the app list."
