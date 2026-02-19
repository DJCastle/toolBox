#!/bin/bash
#
# clone-repos.sh — macOS Repo Sync (Clone & Update)
# ===================================================
#
# PURPOSE:
#   Clones all your GitHub repos into ~/Developer and keeps them updated.
#   Uses an interactive menu so you can choose what to sync.
#   Idempotent — safe to run anytime. Already-cloned repos get pulled.
#
# WHAT IT DOES:
#   1. Authenticates with GitHub (prompts to log in if needed)
#   2. Fetches your full repo list via the GitHub API
#   3. Shows an interactive menu:
#      Option 1) Sync repos tagged for this OS only (macos + cross-platform)
#      Option 2) Sync ALL repos regardless of platform
#      Option 3) Pick specific repos from a numbered list
#   4. Clones missing repos, pulls updates for existing ones
#   5. Prints a summary of what was synced
#
# PLATFORM FILTERING:
#   Repos are filtered by GitHub repository topics:
#     "macos"           → cloned on macOS only
#     "windows"         → cloned on Windows only
#     "cross-platform"  → cloned on both
#     (no topic)        → SKIPPED with a warning
#
#   To tag a new repo:
#     gh repo edit YOUR_USERNAME/<repo> --add-topic macos
#     gh repo edit YOUR_USERNAME/<repo> --add-topic cross-platform
#
# SKIPPED REPOS:
#   The SKIP_REPOS array (line ~34) lists repos managed separately.
#   Add any repos you manage separately to the array below.
#
# USAGE:
#   bash clone-repos.sh              Interactive clone/update
#   bash clone-repos.sh --check      Report only — no changes made
#
# REQUIREMENTS:
#   - gh (GitHub CLI) — installed by brew-setup.sh
#   - jq — installed by brew-setup.sh
#   - Internet connection
#

set -e

# ── Options ──────────────────────────────────────────────────────────
CHECK_ONLY=false
if [[ "$1" == "--check" ]]; then
    CHECK_ONLY=true
fi

# ── Config ───────────────────────────────────────────────────────────
# Leave GITHUB_USER empty to auto-detect from GitHub CLI (gh auth).
# Or set it explicitly: GITHUB_USER="your-username"
GITHUB_USER=""
DEV_DIR="$HOME/Developer"
THIS_PLATFORM="macos"

# Repos to skip (managed separately)
# Example: SKIP_REPOS=("my-private-repo" "another-repo")
SKIP_REPOS=()

# Topics that qualify a repo for this platform
VALID_TOPICS=("macos" "cross-platform")

# ── Auto-detect GitHub user ──────────────────────────────────────────
if [ -z "$GITHUB_USER" ]; then
    GITHUB_USER=$(gh api user --jq '.login' 2>/dev/null || true)
    if [ -z "$GITHUB_USER" ]; then
        echo -e "\033[0;31m[FAIL]\033[0m Could not detect GitHub username."
        echo "       Set GITHUB_USER at the top of this script, or run: gh auth login"
        exit 1
    fi
fi

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
skip()    { echo -e "${DIM}[SKIP]${NC} $1"; }
header()  { echo -e "\n${CYAN}════════════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}════════════════════════════════════════════${NC}\n"; }

# ── Counters ─────────────────────────────────────────────────────────
CLONED=0
PULLED=0
UP_TO_DATE=0
SKIPPED_COUNT=0
FAILED=0

# ── Preflight ────────────────────────────────────────────────────────
if $CHECK_ONLY; then
    header "Repo Sync — Health Check (macOS)"
    info "Running in CHECK mode. No changes will be made."
else
    header "Repo Sync — Clone & Update (macOS)"
fi

if ! command -v gh &>/dev/null; then
    fail "GitHub CLI (gh) not found. Install it first: brew install gh"
    exit 1
fi

if ! gh auth status &>/dev/null 2>&1; then
    warn "GitHub CLI is not authenticated."
    echo ""
    read -rp "$(echo -e "${BLUE}Would you like to log in now? [Y/n]:${NC} ")" LOGIN_CHOICE
    LOGIN_CHOICE="${LOGIN_CHOICE:-Y}"
    if [[ "$LOGIN_CHOICE" =~ ^[Yy]$ ]]; then
        info "Starting GitHub authentication..."
        echo ""
        gh auth login
        echo ""
        # Verify it worked
        if ! gh auth status &>/dev/null 2>&1; then
            fail "Authentication failed. Please try again."
            exit 1
        fi
        success "GitHub CLI authenticated."
    else
        fail "Cannot continue without GitHub authentication."
        exit 1
    fi
else
    success "GitHub CLI authenticated."
fi

if [ ! -d "$DEV_DIR" ]; then
    if $CHECK_ONLY; then
        warn "$DEV_DIR does not exist. Will be created on full run."
    else
        mkdir -p "$DEV_DIR"
        success "Created $DEV_DIR"
    fi
fi

# ── Fetch repo list with topics from GitHub ──────────────────────────
info "Fetching repos from github.com/$GITHUB_USER..."
REPOS_JSON=$(gh repo list "$GITHUB_USER" --limit 100 --json name,isPrivate,repositoryTopics)

if [ -z "$REPOS_JSON" ] || [ "$REPOS_JSON" == "[]" ]; then
    fail "No repos found or failed to fetch."
    exit 1
fi

REPO_COUNT=$(echo "$REPOS_JSON" | jq length)
info "Found $REPO_COUNT repos."

# ── Build repo arrays (excluding skipped) ────────────────────────────
declare -a ALL_NAMES
declare -a ALL_TOPICS
declare -a ALL_PRIVATE
declare -a ALL_PLATFORM_MATCH

eligible=0
for i in $(seq 0 $((REPO_COUNT - 1))); do
    name=$(echo "$REPOS_JSON" | jq -r ".[$i].name")
    is_private=$(echo "$REPOS_JSON" | jq -r ".[$i].isPrivate")
    topics=$(echo "$REPOS_JSON" | jq -r ".[$i].repositoryTopics // [] | map(.name) | join(\",\")")

    # Skip repos managed separately
    skip_it=false
    for skip_repo in "${SKIP_REPOS[@]}"; do
        if [ "$name" == "$skip_repo" ]; then
            skip_it=true
            break
        fi
    done
    $skip_it && continue

    # Check platform match
    match="no"
    if [ -z "$topics" ]; then
        match="untagged"
    else
        for valid in "${VALID_TOPICS[@]}"; do
            if echo "$topics" | grep -q "$valid"; then
                match="yes"
                break
            fi
        done
    fi

    ALL_NAMES+=("$name")
    ALL_TOPICS+=("$topics")
    ALL_PRIVATE+=("$is_private")
    ALL_PLATFORM_MATCH+=("$match")
    ((eligible++))
done

# ── Interactive menu ─────────────────────────────────────────────────
header "Choose Repos"

# Count how many match this platform
platform_count=0
for m in "${ALL_PLATFORM_MATCH[@]}"; do
    [ "$m" == "yes" ] && ((platform_count++))
done

echo -e "  ${BOLD}1)${NC} This OS only (${GREEN}$THIS_PLATFORM${NC} + cross-platform) — ${CYAN}$platform_count repos${NC}"
echo -e "  ${BOLD}2)${NC} All repos — ${CYAN}$eligible repos${NC}"
echo -e "  ${BOLD}3)${NC} Let me pick from a list"
echo ""

# In check mode, default to option 1
if $CHECK_ONLY; then
    info "Check mode — defaulting to this OS only."
    CHOICE="1"
else
    read -rp "$(echo -e "${BLUE}Enter choice [1/2/3]:${NC} ")" CHOICE
fi

# ── Build selected list ──────────────────────────────────────────────
declare -a SELECTED  # indices into ALL_NAMES

case "$CHOICE" in
    1)
        info "Syncing $THIS_PLATFORM repos..."
        for i in "${!ALL_NAMES[@]}"; do
            [ "${ALL_PLATFORM_MATCH[$i]}" == "yes" ] && SELECTED+=("$i")
        done
        ;;
    2)
        info "Syncing ALL repos..."
        for i in "${!ALL_NAMES[@]}"; do
            SELECTED+=("$i")
        done
        ;;
    3)
        echo ""
        echo -e "${BOLD}Available repos:${NC}"
        echo ""
        for i in "${!ALL_NAMES[@]}"; do
            name="${ALL_NAMES[$i]}"
            topics="${ALL_TOPICS[$i]}"
            match="${ALL_PLATFORM_MATCH[$i]}"

            # Platform indicator
            if [ "$match" == "yes" ]; then
                indicator="${GREEN}●${NC}"
            elif [ "$match" == "untagged" ]; then
                indicator="${RED}?${NC}"
            else
                indicator="${DIM}○${NC}"
            fi

            topics_display="$topics"
            [ -z "$topics_display" ] && topics_display="untagged"

            printf "  ${BOLD}%2d)${NC} %b %-30s ${DIM}(%s)${NC}\n" "$((i + 1))" "$indicator" "$name" "$topics_display"
        done

        echo ""
        echo -e "  ${GREEN}●${NC} = this OS   ${DIM}○${NC} = other OS   ${RED}?${NC} = untagged"
        echo ""
        read -rp "$(echo -e "${BLUE}Enter repo numbers (comma-separated, e.g. 1,3,5):${NC} ")" PICKS

        IFS=',' read -ra PICK_ARRAY <<< "$PICKS"
        for pick in "${PICK_ARRAY[@]}"; do
            pick=$(echo "$pick" | tr -d ' ')
            idx=$((pick - 1))
            if [ "$idx" -ge 0 ] && [ "$idx" -lt "$eligible" ]; then
                SELECTED+=("$idx")
            else
                warn "Invalid selection: $pick (skipping)"
            fi
        done
        ;;
    *)
        fail "Invalid choice. Exiting."
        exit 1
        ;;
esac

if [ ${#SELECTED[@]} -eq 0 ]; then
    warn "No repos selected. Nothing to do."
    exit 0
fi

info "Selected ${#SELECTED[@]} repos."

# ── Process selected repos ───────────────────────────────────────────
header "Repositories"

for idx in "${SELECTED[@]}"; do
    name="${ALL_NAMES[$idx]}"
    is_private="${ALL_PRIVATE[$idx]}"
    topics="${ALL_TOPICS[$idx]}"

    visibility="private"
    [ "$is_private" == "false" ] && visibility="public"
    topics_display="$topics"
    [ -z "$topics_display" ] && topics_display="untagged"
    repo_path="$DEV_DIR/$name"

    if [ -d "$repo_path/.git" ]; then
        local_head=$(git -C "$repo_path" rev-parse HEAD 2>/dev/null)
        remote_head=$(git -C "$repo_path" ls-remote origin HEAD 2>/dev/null | awk '{print $1}')

        if [ "$local_head" == "$remote_head" ]; then
            success "$name — up to date ($visibility, $topics_display)"
            ((UP_TO_DATE++))
        else
            if $CHECK_ONLY; then
                warn "$name — UPDATES AVAILABLE ($visibility, $topics_display)"
            else
                info "Pulling $name..."
                if git -C "$repo_path" pull --ff-only 2>/dev/null; then
                    success "$name pulled. ($visibility, $topics_display)"
                    ((PULLED++))
                else
                    warn "$name — pull failed (may have local changes). Fetch only."
                    git -C "$repo_path" fetch 2>/dev/null
                    ((PULLED++))
                fi
            fi
        fi
    elif [ -d "$repo_path" ]; then
        warn "$name — directory exists at $repo_path but is NOT a git repo"
        ((FAILED++))
    else
        if $CHECK_ONLY; then
            warn "$name — NOT CLONED ($visibility, $topics_display)"
            ((SKIPPED_COUNT++))
        else
            info "Cloning $name ($topics_display)..."
            if gh repo clone "$GITHUB_USER/$name" "$repo_path" 2>/dev/null; then
                success "$name cloned. ($visibility, $topics_display)"
                ((CLONED++))
            else
                fail "Failed to clone $name."
                ((FAILED++))
            fi
        fi
    fi
done

# ── Summary ──────────────────────────────────────────────────────────
header "Summary"

echo -e "  ${BLUE}Mode:${NC}             $([ "$CHOICE" == "1" ] && echo "$THIS_PLATFORM only" || ([ "$CHOICE" == "2" ] && echo "all repos" || echo "custom selection"))"
echo ""

if $CHECK_ONLY; then
    echo -e "  ${GREEN}Up to date:${NC}       $UP_TO_DATE"
    echo -e "  ${YELLOW}Not cloned:${NC}       $SKIPPED_COUNT"
    echo ""
    info "Run without --check to clone missing and pull updates."
else
    echo -e "  ${GREEN}Already current:${NC}  $UP_TO_DATE"
    echo -e "  ${GREEN}Newly cloned:${NC}     $CLONED"
    echo -e "  ${GREEN}Pulled updates:${NC}   $PULLED"
    if [ "$FAILED" -gt 0 ]; then
        echo -e "  ${RED}Failed:${NC}           $FAILED"
    fi
    echo ""
    success "Done — repos synced to $DEV_DIR"
fi
