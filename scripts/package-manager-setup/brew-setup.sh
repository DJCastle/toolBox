#!/bin/bash
#
# brew-setup.sh — macOS Dev Environment Setup & Maintenance
# =========================================================
#
# PURPOSE:
#   Single script to bootstrap a fresh macOS system or maintain an
#   existing one. Installs Homebrew, CLI tools, GUI apps (casks), and
#   verifies the dev environment is healthy. Idempotent — safe to run
#   as often as you like.
#
# WHAT IT DOES:
#   1. Installs Xcode Command Line Tools (if missing)
#   2. Installs or updates Homebrew
#   3. Installs/upgrades CLI formulae (gh, node, swiftlint, etc.)
#   4. Installs/upgrades GUI casks (VSCode, etc.)
#   5. Runs brew cleanup to free disk space
#   6. Checks environment health (gh auth, node, claude CLI, Xcode)
#   7. Prints a summary with remaining manual steps
#
# USAGE:
#   bash brew-setup.sh              Full install + upgrade everything
#   bash brew-setup.sh --check      Report only — no changes made
#
# ADDING PACKAGES:
#   - CLI tools: Add to the FORMULAE array (line ~107) as "name|description"
#   - GUI apps:  Add to the CASKS array (line ~175) as "name|description"
#
# REQUIREMENTS:
#   - macOS (tested on Apple Silicon and Intel)
#   - Internet connection
#   - Admin password (for Homebrew install on first run)
#
# APPLE SHORTCUT:
#   To run this from the Shortcuts app:
#     1. Open Shortcuts > New Shortcut
#     2. Add a "Run Shell Script" action
#     3. Paste this launcher script:
#          #!/bin/bash
#          REPO="$HOME/Developer/toolBox"
#          SCRIPT="$REPO/scripts/package-manager-setup/brew-setup.sh"
#          if [ ! -f "$SCRIPT" ]; then
#              mkdir -p "$HOME/Developer"
#              git clone https://github.com/DJCastle/toolBox.git "$REPO"
#          fi
#          osascript -e "tell application \"Terminal\"
#              activate
#              do script \"bash '$SCRIPT'\"
#          end tell"
#

set -e  # Exit on any error

# ── Options ──────────────────────────────────────────────────────────
# Parse command-line flags. --check runs in read-only mode.
CHECK_ONLY=false
if [[ "$1" == "--check" ]]; then
    CHECK_ONLY=true
fi

# ── Colors for output ────────────────────────────────────────────────
# ANSI escape codes for colored terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail()    { echo -e "${RED}[FAIL]${NC} $1"; }
header()  { echo -e "\n${CYAN}════════════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}════════════════════════════════════════════${NC}\n"; }

# ── Counters for summary ─────────────────────────────────────────────
INSTALLED=0
UPGRADED=0
UP_TO_DATE=0
SKIPPED=0
FAILED=0

# ── Mode banner ──────────────────────────────────────────────────────
if $CHECK_ONLY; then
    header "macOS Dev Environment — Health Check"
    info "Running in CHECK mode. No changes will be made."
else
    header "macOS Dev Environment — Setup & Update"
fi

# ── Xcode Command Line Tools ────────────────────────────────────────
info "Checking for Xcode Command Line Tools..."
if xcode-select -p &>/dev/null; then
    success "Xcode Command Line Tools installed."
else
    if $CHECK_ONLY; then
        warn "Xcode Command Line Tools NOT installed."
    else
        info "Installing Xcode Command Line Tools..."
        xcode-select --install
        echo ""
        warn "A dialog will appear to install CLT. Complete that, then re-run this script."
        exit 0
    fi
fi

# ── Homebrew ─────────────────────────────────────────────────────────
info "Checking for Homebrew..."
if command -v brew &>/dev/null; then
    success "Homebrew installed."
    if $CHECK_ONLY; then
        info "Homebrew version: $(brew --version | head -1)"
    else
        info "Updating Homebrew..."
        brew update
        success "Homebrew updated."
    fi
else
    if $CHECK_ONLY; then
        fail "Homebrew NOT installed. Run without --check to install."
    else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ "$(uname -m)" == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        success "Homebrew installed."
    fi
fi

# Bail early if brew isn't available (check mode on fresh system)
if ! command -v brew &>/dev/null; then
    fail "Homebrew not available. Cannot continue."
    exit 1
fi

# ── Gather outdated packages once (avoids repeated slow calls) ───────
info "Checking for outdated packages..."
OUTDATED_LIST=$(brew outdated --formula 2>/dev/null || true)
OUTDATED_CASKS=$(brew outdated --cask 2>/dev/null || true)

# ── Brew Formulae ────────────────────────────────────────────────────
# Each entry: "formula|description"
FORMULAE=(
    # --- Core tools (currently installed) ---
    "gh|GitHub CLI - repos, PRs, issues from the terminal"
    "swiftlint|Swift style and convention enforcement"
    "xcbeautify|Human-readable Xcode build output"

    # --- Development essentials ---
    "node|Node.js runtime (needed by VSCode extensions, Claude Code CLI)"
    "jq|JSON processor for the command line"
    "tree|Directory structure visualizer"
    "wget|File downloader (complements curl)"

    # --- iOS / Swift tooling ---
    "cocoapods|iOS dependency manager"
    "fastlane|iOS build automation and App Store deployment"
    "swiftformat|Swift code auto-formatter"

    # --- macOS utilities ---
    "mas|Mac App Store CLI - install App Store apps via script"
)

header "Formulae"

for entry in "${FORMULAE[@]}"; do
    formula="${entry%%|*}"
    description="${entry##*|}"

    if brew list --formula "$formula" &>/dev/null; then
        # Installed — check if outdated
        if echo "$OUTDATED_LIST" | grep -q "^${formula}$"; then
            current=$(brew list --versions "$formula" | awk '{print $2}')
            latest=$(brew info --json=v2 "$formula" 2>/dev/null | jq -r '.formulae[0].versions.stable // "unknown"')
            if $CHECK_ONLY; then
                warn "$formula — UPDATE AVAILABLE ($current → $latest) — $description"
            else
                info "Upgrading $formula ($current → $latest)..."
                if brew upgrade "$formula"; then
                    success "$formula upgraded to $latest."
                    ((UPGRADED++))
                else
                    fail "Failed to upgrade $formula. Continuing..."
                    ((FAILED++))
                fi
            fi
        else
            version=$(brew list --versions "$formula" | awk '{print $2}')
            success "$formula $version — up to date ($description)"
            ((UP_TO_DATE++))
        fi
    else
        # Not installed
        if $CHECK_ONLY; then
            warn "$formula — NOT INSTALLED — $description"
            ((SKIPPED++))
        else
            info "Installing $formula — $description"
            if brew install "$formula"; then
                success "$formula installed."
                ((INSTALLED++))
            else
                fail "Failed to install $formula. Continuing..."
                ((FAILED++))
            fi
        fi
    fi
done

# ── Brew Casks (GUI applications) ─────────────────────────────────────
# Each entry: "cask|description"
CASKS=(
    "visual-studio-code|Visual Studio Code editor"
)

header "Casks (Applications)"

for entry in "${CASKS[@]}"; do
    cask="${entry%%|*}"
    description="${entry##*|}"

    if brew list --cask "$cask" &>/dev/null; then
        # Installed — check if outdated
        if echo "$OUTDATED_CASKS" | grep -q "^${cask}$"; then
            if $CHECK_ONLY; then
                warn "$cask — UPDATE AVAILABLE — $description"
            else
                info "Upgrading $cask..."
                if brew upgrade --cask "$cask"; then
                    success "$cask upgraded."
                    ((UPGRADED++))
                else
                    fail "Failed to upgrade $cask. Continuing..."
                    ((FAILED++))
                fi
            fi
        else
            version=$(brew list --cask --versions "$cask" | awk '{print $2}')
            success "$cask $version — up to date ($description)"
            ((UP_TO_DATE++))
        fi
    else
        # Not installed
        if $CHECK_ONLY; then
            warn "$cask — NOT INSTALLED — $description"
            ((SKIPPED++))
        else
            info "Installing $cask — $description"
            if brew install --cask "$cask"; then
                success "$cask installed."
                ((INSTALLED++))
            else
                fail "Failed to install $cask. Continuing..."
                ((FAILED++))
            fi
        fi
    fi
done

# ── Cleanup (only in full mode) ──────────────────────────────────────
if ! $CHECK_ONLY; then
    echo ""
    info "Cleaning up old versions and cache..."
    brew cleanup
    success "Cleanup complete."
fi

# ── Post-install checks ─────────────────────────────────────────────
header "Environment Health"

# GitHub CLI auth
if command -v gh &>/dev/null; then
    if gh auth status &>/dev/null; then
        success "GitHub CLI authenticated."
    else
        warn "GitHub CLI installed but NOT authenticated. Run: gh auth login"
    fi
fi

# Node.js
if command -v node &>/dev/null; then
    success "Node.js $(node --version) ready."
else
    warn "Node.js not found on PATH. Restart your shell if just installed."
fi

# VSCode
if command -v code &>/dev/null; then
    success "VSCode ready."
else
    warn "VSCode not found on PATH. Restart your shell if just installed."
fi

# Claude Code CLI
if command -v claude &>/dev/null; then
    success "Claude Code CLI installed."
else
    warn "Claude Code CLI not installed. Run: npm install -g @anthropic-ai/claude-code"
fi

# CocoaPods
if command -v pod &>/dev/null; then
    if ! $CHECK_ONLY; then
        info "Verifying CocoaPods setup..."
        pod setup 2>/dev/null || warn "CocoaPods setup skipped (may need Xcode first)."
    fi
    success "CocoaPods ready."
fi

# Fastlane
if command -v fastlane &>/dev/null; then
    success "Fastlane ready."
fi

# Xcode
if [ -d "/Applications/Xcode.app" ]; then
    success "Xcode installed."
else
    warn "Xcode not installed. Run: mas install 497799835"
fi

# ── Summary ──────────────────────────────────────────────────────────
header "Summary"

TOTAL_PACKAGES=$(( ${#FORMULAE[@]} + ${#CASKS[@]} ))

if $CHECK_ONLY; then
    OUTDATED_COUNT=$(( TOTAL_PACKAGES - UP_TO_DATE - SKIPPED ))
    echo -e "  ${GREEN}Up to date:${NC}  $UP_TO_DATE"
    echo -e "  ${YELLOW}Outdated:${NC}    $OUTDATED_COUNT"
    echo -e "  ${RED}Missing:${NC}     $SKIPPED"
    echo ""
    if [ "$SKIPPED" -gt 0 ] || [ "$OUTDATED_COUNT" -gt 0 ]; then
        info "Run without --check to install missing and upgrade outdated packages."
    else
        success "Everything is up to date."
    fi
else
    echo -e "  ${GREEN}Already current:${NC}  $UP_TO_DATE"
    echo -e "  ${GREEN}Newly installed:${NC}  $INSTALLED"
    echo -e "  ${GREEN}Upgraded:${NC}         $UPGRADED"
    if [ "$FAILED" -gt 0 ]; then
        echo -e "  ${RED}Failed:${NC}           $FAILED"
    fi
    echo ""
    info "Remaining manual steps:"
    if ! gh auth status &>/dev/null 2>&1; then
        echo "  1. gh auth login          — Authenticate GitHub CLI"
    fi
    if ! command -v claude &>/dev/null; then
        echo "  2. npm install -g @anthropic-ai/claude-code"
    fi
    if [ ! -d "/Applications/Xcode.app" ]; then
        echo "  3. mas install 497799835  — Install Xcode from App Store"
    fi
    echo ""
    success "You're good to go."
fi
