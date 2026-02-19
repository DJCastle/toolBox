<#
.SYNOPSIS
    Windows Repo Sync — Clone & Update GitHub repos into ~\Developer.

.DESCRIPTION
    Clones all your GitHub repos into ~\Developer and keeps them updated.
    Uses an interactive menu so you can choose what to sync.
    Idempotent — safe to run anytime. Already-cloned repos get pulled.

    WHAT IT DOES:
      1. Authenticates with GitHub (prompts to log in if needed)
      2. Fetches your full repo list via the GitHub API
      3. Shows an interactive menu:
         Option 1) Sync repos tagged for this OS only (windows + cross-platform)
         Option 2) Sync ALL repos regardless of platform
         Option 3) Pick specific repos from a numbered list
      4. Clones missing repos, pulls updates for existing ones
      5. Prints a summary of what was synced

    PLATFORM FILTERING (via GitHub repo topics):
      "windows"         - cloned on Windows only
      "cross-platform"  - cloned on both macOS and Windows
      "macos"           - skipped on Windows (unless you manually pick it)
      (no topic)        - SKIPPED with a warning — tag your repos!

    To tag a new repo:
      gh repo edit YOUR_USERNAME/<repo> --add-topic windows
      gh repo edit YOUR_USERNAME/<repo> --add-topic cross-platform

    SKIPPED REPOS:
      The $SkipRepos array lists repos managed separately.
      Add any repos you manage separately to the array below.

    REQUIREMENTS:
      - gh (GitHub CLI) — installed by choco-setup.ps1
      - Internet connection

.PARAMETER Check
    Report only — no changes made. Shows what's cloned, outdated, or missing.

.EXAMPLE
    .\clone-repos.ps1              Interactive clone/update
    .\clone-repos.ps1 -Check       Report only — no changes made
#>

param(
    [switch]$Check
)

$ErrorActionPreference = "Continue"

# ── Config ───────────────────────────────────────────────────────────
# Leave $GitHubUser empty to auto-detect from GitHub CLI (gh auth).
# Or set it explicitly: $GitHubUser = "your-username"
$GitHubUser = ""
$DevDir = Join-Path $env:USERPROFILE "Developer"
$ThisPlatform = "windows"

# Repos to skip (managed separately)
# Example: $SkipRepos = @("my-private-repo", "another-repo")
$SkipRepos = @()

# Topics that qualify a repo for this platform
$ValidTopics = @("windows", "cross-platform")

# ── Auto-detect GitHub user ──────────────────────────────────────────
if (-not $GitHubUser) {
    try {
        $GitHubUser = (gh api user --jq '.login' 2>$null)
    } catch {}
    if (-not $GitHubUser) {
        Write-Host "[FAIL] " -ForegroundColor Red -NoNewline
        Write-Host "Could not detect GitHub username."
        Write-Host "       Set `$GitHubUser at the top of this script, or run: gh auth login"
        exit 1
    }
}

# ── Output helpers ───────────────────────────────────────────────────
function Write-Info    { param($Msg) Write-Host "[INFO] " -ForegroundColor Blue -NoNewline; Write-Host $Msg }
function Write-Ok      { param($Msg) Write-Host "[OK]   " -ForegroundColor Green -NoNewline; Write-Host $Msg }
function Write-Warn    { param($Msg) Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline; Write-Host $Msg }
function Write-Fail    { param($Msg) Write-Host "[FAIL] " -ForegroundColor Red -NoNewline; Write-Host $Msg }
function Write-Skip    { param($Msg) Write-Host "[SKIP] " -ForegroundColor DarkGray -NoNewline; Write-Host $Msg }
function Write-Header  { param($Msg)
    Write-Host ""
    Write-Host ("=" * 48) -ForegroundColor Cyan
    Write-Host "  $Msg" -ForegroundColor Cyan
    Write-Host ("=" * 48) -ForegroundColor Cyan
    Write-Host ""
}

# ── Counters ─────────────────────────────────────────────────────────
$script:Cloned       = 0
$script:Pulled       = 0
$script:UpToDate     = 0
$script:SkippedCount = 0
$script:Failed       = 0

# ── Preflight ────────────────────────────────────────────────────────
if ($Check) {
    Write-Header "Repo Sync — Health Check (Windows)"
    Write-Info "Running in CHECK mode. No changes will be made."
} else {
    Write-Header "Repo Sync — Clone & Update (Windows)"
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Fail "GitHub CLI (gh) not found. Install it first: choco install gh"
    exit 1
}

$authCheck = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Warn "GitHub CLI is not authenticated."
    Write-Host ""
    $loginChoice = Read-Host "  Would you like to log in now? [Y/n]"
    if (-not $loginChoice) { $loginChoice = "Y" }
    if ($loginChoice -match '^[Yy]$') {
        Write-Info "Starting GitHub authentication..."
        Write-Host ""
        gh auth login
        Write-Host ""
        # Verify it worked
        $recheck = gh auth status 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "Authentication failed. Please try again."
            exit 1
        }
        Write-Ok "GitHub CLI authenticated."
    } else {
        Write-Fail "Cannot continue without GitHub authentication."
        exit 1
    }
} else {
    Write-Ok "GitHub CLI authenticated."
}

if (-not (Test-Path $DevDir)) {
    if ($Check) {
        Write-Warn "$DevDir does not exist. Will be created on full run."
    } else {
        New-Item -ItemType Directory -Path $DevDir -Force | Out-Null
        Write-Ok "Created $DevDir"
    }
}

# ── Fetch repo list with topics from GitHub ──────────────────────────
Write-Info "Fetching repos from github.com/$GitHubUser..."
$reposJson = gh repo list $GitHubUser --limit 100 --json name,isPrivate,repositoryTopics 2>$null | ConvertFrom-Json

if (-not $reposJson -or $reposJson.Count -eq 0) {
    Write-Fail "No repos found or failed to fetch."
    exit 1
}

Write-Info "Found $($reposJson.Count) repos."

# ── Build repo list (excluding skipped) ──────────────────────────────
$allRepos = @()

foreach ($repo in $reposJson) {
    if ($SkipRepos -contains $repo.name) { continue }

    $topics = @()
    if ($repo.repositoryTopics) {
        $topics = $repo.repositoryTopics | ForEach-Object { $_.name }
    }

    $match = "no"
    if ($topics.Count -eq 0) {
        $match = "untagged"
    } else {
        foreach ($t in $topics) {
            if ($ValidTopics -contains $t) {
                $match = "yes"
                break
            }
        }
    }

    $allRepos += [PSCustomObject]@{
        Name          = $repo.name
        IsPrivate     = $repo.isPrivate
        Topics        = ($topics -join ", ")
        PlatformMatch = $match
    }
}

$eligible = $allRepos.Count
$platformCount = ($allRepos | Where-Object { $_.PlatformMatch -eq "yes" }).Count

# ── Interactive menu ─────────────────────────────────────────────────
Write-Header "Choose Repos"

Write-Host "  1) " -NoNewline -ForegroundColor White
Write-Host "This OS only (" -NoNewline
Write-Host $ThisPlatform -NoNewline -ForegroundColor Green
Write-Host " + cross-platform) — " -NoNewline
Write-Host "$platformCount repos" -ForegroundColor Cyan

Write-Host "  2) " -NoNewline -ForegroundColor White
Write-Host "All repos — " -NoNewline
Write-Host "$eligible repos" -ForegroundColor Cyan

Write-Host "  3) " -NoNewline -ForegroundColor White
Write-Host "Let me pick from a list"

Write-Host ""

if ($Check) {
    Write-Info "Check mode — defaulting to this OS only."
    $choice = "1"
} else {
    $choice = Read-Host "  Enter choice [1/2/3]"
}

# ── Build selected list ──────────────────────────────────────────────
$selectedRepos = @()

switch ($choice) {
    "1" {
        Write-Info "Syncing $ThisPlatform repos..."
        $selectedRepos = $allRepos | Where-Object { $_.PlatformMatch -eq "yes" }
    }
    "2" {
        Write-Info "Syncing ALL repos..."
        $selectedRepos = $allRepos
    }
    "3" {
        Write-Host ""
        Write-Host "  Available repos:" -ForegroundColor White
        Write-Host ""

        for ($i = 0; $i -lt $allRepos.Count; $i++) {
            $r = $allRepos[$i]
            $num = "{0,3}" -f ($i + 1)

            # Platform indicator
            switch ($r.PlatformMatch) {
                "yes"      { $indicator = "●"; $color = "Green" }
                "untagged" { $indicator = "?"; $color = "Red" }
                default    { $indicator = "○"; $color = "DarkGray" }
            }

            $topicsDisplay = if ($r.Topics) { $r.Topics } else { "untagged" }

            Write-Host "  $num) " -NoNewline -ForegroundColor White
            Write-Host "$indicator " -NoNewline -ForegroundColor $color
            Write-Host ("{0,-30}" -f $r.Name) -NoNewline
            Write-Host " ($topicsDisplay)" -ForegroundColor DarkGray
        }

        Write-Host ""
        Write-Host "  ● = this OS   ○ = other OS   ? = untagged" -ForegroundColor DarkGray
        Write-Host ""
        $picks = Read-Host "  Enter repo numbers (comma-separated, e.g. 1,3,5)"

        $pickNums = $picks -split ',' | ForEach-Object { $_.Trim() }
        foreach ($p in $pickNums) {
            $idx = [int]$p - 1
            if ($idx -ge 0 -and $idx -lt $eligible) {
                $selectedRepos += $allRepos[$idx]
            } else {
                Write-Warn "Invalid selection: $p (skipping)"
            }
        }
    }
    default {
        Write-Fail "Invalid choice. Exiting."
        exit 1
    }
}

if ($selectedRepos.Count -eq 0) {
    Write-Warn "No repos selected. Nothing to do."
    exit 0
}

Write-Info "Selected $($selectedRepos.Count) repos."

# ── Process selected repos ───────────────────────────────────────────
Write-Header "Repositories"

foreach ($r in $selectedRepos) {
    $name = $r.Name
    $visibility = if ($r.IsPrivate) { "private" } else { "public" }
    $topicsDisplay = if ($r.Topics) { $r.Topics } else { "untagged" }
    $repoPath = Join-Path $DevDir $name
    $gitDir = Join-Path $repoPath ".git"

    if (Test-Path $gitDir) {
        $localHead = git -C $repoPath rev-parse HEAD 2>$null
        $remoteInfo = git -C $repoPath ls-remote origin HEAD 2>$null
        $remoteHead = if ($remoteInfo) { ($remoteInfo -split '\s')[0] } else { "" }

        if ($localHead -eq $remoteHead) {
            Write-Ok "$name — up to date ($visibility, $topicsDisplay)"
            $script:UpToDate++
        } else {
            if ($Check) {
                Write-Warn "$name — UPDATES AVAILABLE ($visibility, $topicsDisplay)"
            } else {
                Write-Info "Pulling $name..."
                $pullResult = git -C $repoPath pull --ff-only 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Ok "$name pulled. ($visibility, $topicsDisplay)"
                    $script:Pulled++
                } else {
                    Write-Warn "$name — pull failed (may have local changes). Fetch only."
                    git -C $repoPath fetch 2>$null
                    $script:Pulled++
                }
            }
        }
    } elseif (Test-Path $repoPath) {
        Write-Warn "$name — directory exists at $repoPath but is NOT a git repo"
        $script:Failed++
    } else {
        if ($Check) {
            Write-Warn "$name — NOT CLONED ($visibility, $topicsDisplay)"
            $script:SkippedCount++
        } else {
            Write-Info "Cloning $name ($topicsDisplay)..."
            $cloneResult = gh repo clone "$GitHubUser/$name" $repoPath 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Ok "$name cloned. ($visibility, $topicsDisplay)"
                $script:Cloned++
            } else {
                Write-Fail "Failed to clone $name."
                $script:Failed++
            }
        }
    }
}

# ── Summary ──────────────────────────────────────────────────────────
Write-Header "Summary"

$modeLabel = switch ($choice) {
    "1" { "$ThisPlatform only" }
    "2" { "all repos" }
    "3" { "custom selection" }
}
Write-Host "  Mode:             $modeLabel" -ForegroundColor Blue
Write-Host ""

if ($Check) {
    Write-Host "  Up to date:       $($script:UpToDate)" -ForegroundColor Green
    Write-Host "  Not cloned:       $($script:SkippedCount)" -ForegroundColor Yellow
    Write-Host ""
    Write-Info "Run without -Check to clone missing and pull updates."
} else {
    Write-Host "  Already current:  $($script:UpToDate)" -ForegroundColor Green
    Write-Host "  Newly cloned:     $($script:Cloned)" -ForegroundColor Green
    Write-Host "  Pulled updates:   $($script:Pulled)" -ForegroundColor Green
    if ($script:Failed -gt 0) {
        Write-Host "  Failed:           $($script:Failed)" -ForegroundColor Red
    }
    Write-Host ""
    Write-Ok "Done — repos synced to $DevDir"
}
