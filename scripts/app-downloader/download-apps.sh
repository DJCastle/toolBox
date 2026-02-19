#!/bin/bash
#
# download-apps.sh — macOS App Installer Downloader
# ===================================================
#
# PURPOSE:
#   Downloads DMG installer files for apps that aren't on the Mac App Store.
#   Puts them in ~/Downloads for you to install manually.
#   Does NOT install anything — just downloads.
#
# HOW IT WORKS:
#   1. Queries Homebrew cask definitions for the latest download URLs
#      (this ensures URLs are always up-to-date and from trusted vendors)
#   2. Compares remote version against a local version file to detect updates
#   3. Downloads each DMG with a progress bar (skips if already up-to-date)
#   4. Shows speed, file size, and elapsed time for each download
#
# ADDING APPS:
#   Add the Homebrew cask token to the CASK_TOKENS array (line ~54).
#   Find cask names with: brew search --cask <app-name>
#
# APPS INCLUDED:
#   - Google Chrome       (google-chrome)
#   - Grammarly Desktop   (grammarly-desktop)
#   - Bambu Studio        (bambu-studio)
#   - Brave Browser       (brave-browser)
#
# USAGE:
#   bash download-apps.sh              Download all apps
#   bash download-apps.sh --check      Report only — no downloads
#
# REQUIREMENTS:
#   - brew (Homebrew) — for fetching trusted download URLs
#   - curl (built-in on macOS)
#   - jq — installed by brew-setup.sh
#

set -e

# ── Options ──────────────────────────────────────────────────────────
CHECK_ONLY=false
if [[ "$1" == "--check" ]]; then
    CHECK_ONLY=true
fi

# ── Config ───────────────────────────────────────────────────────────
DOWNLOAD_DIR="$HOME/Downloads"
VERSION_FILE="$DOWNLOAD_DIR/.download-app-versions"

# ── Colors ───────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail()    { echo -e "${RED}[FAIL]${NC} $1"; }
header()  { echo -e "\n${CYAN}════════════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}════════════════════════════════════════════${NC}\n"; }

# ── App list (cask tokens) ───────────────────────────────────────────
# Add or remove cask tokens here. URLs are fetched live from brew.
# Find cask names at: https://formulae.brew.sh/cask/
#
# To customize: Edit this array with your preferred apps.
# Examples: firefox, iterm2, docker, zoom, spotify, discord
CASK_TOKENS=(
    "google-chrome"
    "brave-browser"
    "visual-studio-code"
    "slack"
)

# ── Version tracking helpers ─────────────────────────────────────────
# Reads a saved version for a given cask token from the version file.
get_saved_version() {
    local token="$1"
    if [ -f "$VERSION_FILE" ]; then
        grep "^${token}=" "$VERSION_FILE" 2>/dev/null | cut -d'=' -f2
    fi
}

# Saves the current version for a cask token after a successful download.
save_version() {
    local token="$1" version="$2"
    if [ -f "$VERSION_FILE" ]; then
        # Remove old entry, then append new one
        grep -v "^${token}=" "$VERSION_FILE" > "${VERSION_FILE}.tmp" 2>/dev/null || true
        mv "${VERSION_FILE}.tmp" "$VERSION_FILE"
    fi
    echo "${token}=${version}" >> "$VERSION_FILE"
}

# ── Counters ─────────────────────────────────────────────────────────
DOWNLOADED=0
UP_TO_DATE=0
SKIPPED=0
FAILED=0
UPDATED=0
TOTAL=${#CASK_TOKENS[@]}

# ── Preflight ────────────────────────────────────────────────────────
if $CHECK_ONLY; then
    header "App Downloader — Check Mode"
    info "Running in CHECK mode. No downloads will be made."
else
    header "App Downloader"
fi

if ! command -v brew &>/dev/null; then
    fail "Homebrew not found. Run brew-setup.sh first."
    exit 1
fi

# ── Fetch app info from brew cask definitions ────────────────────────
info "Fetching latest download URLs from Homebrew casks..."
echo ""

CASK_LIST=$(printf "%s " "${CASK_TOKENS[@]}")
CASK_JSON=$(brew info --cask --json=v2 $CASK_LIST 2>/dev/null)

if [ -z "$CASK_JSON" ]; then
    fail "Failed to fetch cask info from Homebrew."
    exit 1
fi

# ── Process each app ─────────────────────────────────────────────────
header "Applications"

CURRENT=0
for token in "${CASK_TOKENS[@]}"; do
    ((CURRENT++))

    # Extract info from JSON
    name=$(echo "$CASK_JSON" | jq -r ".casks[] | select(.token == \"$token\") | .name[0]")
    url=$(echo "$CASK_JSON" | jq -r ".casks[] | select(.token == \"$token\") | .url")
    version=$(echo "$CASK_JSON" | jq -r ".casks[] | select(.token == \"$token\") | .version")

    if [ -z "$url" ] || [ "$url" == "null" ]; then
        fail "[$CURRENT/$TOTAL] $token — could not find download URL"
        ((FAILED++))
        continue
    fi

    # Determine filename from URL
    filename=$(basename "$url")

    # Check if app is already installed
    app_installed=false
    app_path=$(echo "$CASK_JSON" | jq -r ".casks[] | select(.token == \"$token\") | .artifacts[] | .app? // empty | .[]?" 2>/dev/null | head -1)
    if [ -n "$app_path" ] && [ -d "/Applications/$app_path" ]; then
        app_installed=true
    fi

    # Check saved version vs current version from brew
    saved_ver=$(get_saved_version "$token")
    is_update=false

    echo -e "${BOLD}[$CURRENT/$TOTAL] $name${NC} (v$version)"
    echo -e "  ${DIM}URL: $url${NC}"
    echo -e "  ${DIM}File: $filename${NC}"

    if $app_installed; then
        echo -e "  ${GREEN}Already installed in /Applications${NC}"
    fi

    dest="$DOWNLOAD_DIR/$filename"

    if [ -f "$dest" ]; then
        if [ -n "$saved_ver" ] && [ "$saved_ver" != "$version" ]; then
            # Version changed since last download — update available
            is_update=true
            echo -e "  ${YELLOW}Update available: v${saved_ver} → v${version}${NC}"

            if $CHECK_ONLY; then
                warn "$name — update available (v${saved_ver} → v${version})"
                echo ""
                continue
            fi

            echo ""
            read -rp "$(echo -e "  ${BLUE}Download update? [Y/n]:${NC} ")" DO_UPDATE
            if [[ "$DO_UPDATE" =~ ^[Nn]$ ]]; then
                success "$name — skipped update"
                ((SKIPPED++))
                echo ""
                continue
            fi
        else
            # Same version — up to date
            echo -e "  ${GREEN}Already downloaded (v${version}) — up to date${NC}"

            if $CHECK_ONLY; then
                success "$name — up to date (v${version})"
                ((UP_TO_DATE++))
                echo ""
                continue
            fi

            echo ""
            read -rp "$(echo -e "  ${BLUE}Re-download anyway? [y/N]:${NC} ")" REDOWNLOAD
            if [[ ! "$REDOWNLOAD" =~ ^[Yy]$ ]]; then
                success "$name — skipped (up to date)"
                ((UP_TO_DATE++))
                echo ""
                continue
            fi
        fi
    else
        if $CHECK_ONLY; then
            if $app_installed; then
                warn "$name — installed but DMG not in Downloads"
            else
                warn "$name — NOT downloaded"
            fi
            echo ""
            continue
        fi
    fi

    # Download with progress
    echo ""
    if $is_update; then
        info "Updating $name (v${saved_ver} → v${version})..."
    else
        info "Downloading $name (v${version})..."
    fi
    echo ""

    if curl -L \
        --progress-bar \
        --fail \
        --output "$dest" \
        --write-out "  Speed: %{speed_download} bytes/sec | Time: %{time_total}s | Size: %{size_download} bytes\n" \
        "$url"; then
        echo ""
        # Get file size in human readable format
        file_size=$(ls -lh "$dest" | awk '{print $5}')
        save_version "$token" "$version"
        if $is_update; then
            success "$name updated to v${version} — $file_size → $dest"
            ((UPDATED++))
        else
            success "$name downloaded (v${version}) — $file_size → $dest"
            ((DOWNLOADED++))
        fi
    else
        echo ""
        fail "$name — download failed"
        # Clean up partial download
        rm -f "$dest"
        ((FAILED++))
    fi

    echo ""
done

# ── Summary ──────────────────────────────────────────────────────────
header "Summary"

echo -e "  ${BLUE}Download folder:${NC}  $DOWNLOAD_DIR"
echo ""

if $CHECK_ONLY; then
    echo -e "  ${GREEN}Up to date:${NC}     $UP_TO_DATE"
    echo -e "  ${YELLOW}Not downloaded:${NC} $((TOTAL - UP_TO_DATE))"
    echo ""
    info "Run without --check to download."
else
    echo -e "  ${GREEN}Downloaded:${NC}     $DOWNLOADED"
    if [ "$UPDATED" -gt 0 ]; then
        echo -e "  ${CYAN}Updated:${NC}        $UPDATED"
    fi
    echo -e "  ${GREEN}Up to date:${NC}     $UP_TO_DATE"
    echo -e "  ${YELLOW}Skipped:${NC}        $SKIPPED"
    if [ "$FAILED" -gt 0 ]; then
        echo -e "  ${RED}Failed:${NC}         $FAILED"
    fi
    echo ""
    if [ "$DOWNLOADED" -gt 0 ] || [ "$UPDATED" -gt 0 ] || [ "$SKIPPED" -gt 0 ]; then
        info "Installers are in $DOWNLOAD_DIR"
        info "Open each DMG and drag to /Applications to install."
    fi
fi

echo ""
success "Done."
