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
echo "Note: This shell script uses hardcoded URLs. For automatic latest-version"
echo "resolution via Homebrew Cask, use the AppleScript app instead (see automator/non-appstore-download/)."
echo ""

# Resolve a Homebrew Cask URL and download it
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
