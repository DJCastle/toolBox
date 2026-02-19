#!/bin/bash
#
# download-apps.sh — Non App Store Apps Download (macOS)
# ======================================================
#
# PURPOSE:
#   Downloads DMG/ZIP installer files for apps that aren't on the Mac
#   App Store. Puts them on ~/Desktop for you to install manually.
#   Does NOT install anything — just downloads.
#
# HOW IT WORKS:
#   1. Queries the Homebrew Cask API for the latest download URLs
#      (no Homebrew installation required — uses the public API only)
#   2. Downloads each file to ~/Desktop with curl
#   3. Shows color-coded status for each app
#
# ADDING APPS:
#   Add a new brew_download call at the bottom of this script:
#     brew_download "Display Name" "cask-name"
#   Find cask names at: https://formulae.brew.sh/cask/
#
# APPS INCLUDED:
#   - Google Chrome       (google-chrome)
#   - Brave Browser       (brave-browser)
#   - Visual Studio Code  (visual-studio-code)
#   - Slack               (slack)
#   - iTerm2              (iterm2)
#
# USAGE:
#   bash download-apps.sh
#
# REQUIREMENTS:
#   - macOS (any recent version)
#   - Internet connection
#   - Python 3 (included with macOS)
#
# NOTE:
#   For a newer version with --check mode, version tracking, and
#   Windows support, see scripts/app-downloader/ instead.
#

set -e

# ── Config ───────────────────────────────────────────────────────────
DEST="$HOME/Desktop"

# ── Colors ───────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── Output helpers ───────────────────────────────────────────────────
info()    { echo -e "${BLUE}[downloading]${NC} $1..."; }
success() { echo -e "${GREEN}[done]${NC} $1"; }
fail()    { echo -e "${RED}[failed]${NC} $1"; }

# ── Download function (direct URL — unused, kept for reference) ──────
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

# ── Resolve a Homebrew Cask URL and download it ─────────────────────
# Queries the public Homebrew Cask API to get the latest stable
# download URL for any cask. No Homebrew installation required.
brew_download() {
    local name="$1" cask="$2"
    info "$name"
    local json url file
    json=$(curl -s --connect-timeout 10 --max-time 15 "https://formulae.brew.sh/api/cask/${cask}.json" 2>/dev/null)
    url=$(echo "$json" | python3 -c "import sys,json; print(json.load(sys.stdin).get('url',''))" 2>/dev/null)
    file=$(basename "$url")
    if [ -n "$url" ] && curl -L -o "$DEST/$file" "$url" 2>/dev/null; then
        success "$name → ~/Desktop/$file"
    else
        fail "$name"
    fi
}

# ── App list ────────────────────────────────────────────────────────
# Add or remove apps below. Each call takes a display name and a
# Homebrew cask name. Find cask names at: https://formulae.brew.sh/cask/
#
# To customize: Add a new line like:
#   brew_download "Firefox" "firefox"

# Google Chrome
brew_download "Google Chrome" "google-chrome"

# Brave Browser
brew_download "Brave Browser" "brave-browser"

# Visual Studio Code
brew_download "Visual Studio Code" "visual-studio-code"

# Slack
brew_download "Slack" "slack"

# iTerm2
brew_download "iTerm2" "iterm2"

echo ""
echo -e "${GREEN}All downloads saved to ~/Desktop${NC}"
echo "Open the .dmg files to install, or unzip the .zip files to get the .app"
