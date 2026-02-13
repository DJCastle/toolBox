#!/bin/bash
set -e

DEST="$HOME/Desktop"

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[downloading]${NC} $1..."; }
success() { echo -e "${GREEN}[done]${NC} $1"; }
fail()    { echo -e "${RED}[failed]${NC} $1"; }

download() {
    local name="$1" url="$2" file="$3"
    info "$name"
    if curl -L -o "$DEST/$file" "$url" 2>/dev/null; then
        success "$name → ~/Desktop/$file"
    else
        fail "$name"
    fi
}

echo "Downloading apps to Desktop..."
echo ""

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

# Visual Studio Code
download "Visual Studio Code" \
    "https://update.code.visualstudio.com/latest/darwin-arm64/stable" \
    "VSCode-arm64.zip"

echo ""
echo -e "${GREEN}All downloads saved to ~/Desktop${NC}"
echo "Open the .dmg files to install, or unzip the .zip files to get the .app"
