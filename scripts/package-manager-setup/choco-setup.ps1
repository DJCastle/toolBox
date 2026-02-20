#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows Dev Environment Setup & Maintenance (Chocolatey)

.DESCRIPTION
    Single script to bootstrap a fresh Windows system or maintain an existing one.
    Installs Chocolatey, CLI tools, GUI apps, and verifies environment health.
    Idempotent — safe to run as often as you like.

    WHAT IT DOES:
      1. Installs or updates Chocolatey package manager
      2. Installs/upgrades CLI tools (git, gh, node, python, jq, etc.)
      3. Installs/upgrades GUI apps (VSCode, Windows Terminal, etc.)
      4. Checks environment health (git, gh auth, node, claude CLI, pwsh)
      5. Prints a summary with remaining manual steps

    ADDING PACKAGES:
      Add to the $Packages array (~line 47) as:
        @{ Name = "choco-package-id"; Desc = "description" }

    REQUIREMENTS:
      - Windows 10/11
      - Must be run as Administrator (Chocolatey requires elevated privileges)
      - Internet connection

.PARAMETER Check
    Report only — no changes made. Shows what's installed, outdated, or missing.

.EXAMPLE
    .\choco-setup.ps1                 Full install + upgrade everything
    .\choco-setup.ps1 -Check          Report only — no changes made

.NOTES
    POWER AUTOMATE DESKTOP (PAD) FLOW:
      To run this from PAD:
        1. Open Power Automate Desktop > New Flow
        2. Add a "Run PowerShell script" action
        3. Paste this launcher script:

             $ScriptDir = Join-Path $env:USERPROFILE "Developer\toolBox"
             $Script = Join-Path $ScriptDir "scripts\package-manager-setup\choco-setup.ps1"
             if (-not (Test-Path $Script)) {
                 New-Item -ItemType Directory -Force -Path (Join-Path $env:USERPROFILE "Developer") | Out-Null
                 git clone https://github.com/DJCastle/toolBox.git $ScriptDir 2>$null
             }
             Start-Process powershell -Verb RunAs -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "`"$Script`""
#>

param(
    [switch]$Check
)

$ErrorActionPreference = "Continue"

# ── Colors / Output helpers ──────────────────────────────────────────
function Write-Info    { param($Msg) Write-Host "[INFO] " -ForegroundColor Blue -NoNewline; Write-Host $Msg }
function Write-Ok      { param($Msg) Write-Host "[OK]   " -ForegroundColor Green -NoNewline; Write-Host $Msg }
function Write-Warn    { param($Msg) Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline; Write-Host $Msg }
function Write-Fail    { param($Msg) Write-Host "[FAIL] " -ForegroundColor Red -NoNewline; Write-Host $Msg }
function Write-Header  { param($Msg)
    Write-Host ""
    Write-Host ("=" * 48) -ForegroundColor Cyan
    Write-Host "  $Msg" -ForegroundColor Cyan
    Write-Host ("=" * 48) -ForegroundColor Cyan
    Write-Host ""
}

# ── Counters ─────────────────────────────────────────────────────────
$script:Installed  = 0
$script:Upgraded   = 0
$script:UpToDate   = 0
$script:Skipped    = 0
$script:Failed     = 0

# ── Package list ─────────────────────────────────────────────────────
# Each entry: @{ Name = "choco-package-id"; Desc = "description" }
$Packages = @(
    # --- Development essentials ---
    @{ Name = "git";               Desc = "Git version control" }
    @{ Name = "gh";                Desc = "GitHub CLI - repos, PRs, issues from the terminal" }
    @{ Name = "nodejs-lts";        Desc = "Node.js LTS runtime (needed by VSCode extensions, Claude Code CLI)" }
    @{ Name = "python3";           Desc = "Python 3 runtime" }
    @{ Name = "jq";                Desc = "JSON processor for the command line" }
    @{ Name = "wget";              Desc = "File downloader (complements curl)" }

    # --- Editors / IDEs ---
    @{ Name = "vscode";            Desc = "Visual Studio Code" }

    # --- Terminal / Shell ---
    @{ Name = "microsoft-windows-terminal"; Desc = "Windows Terminal" }
    @{ Name = "powershell-core";   Desc = "PowerShell 7+ (modern cross-platform shell)" }

    # --- Utilities ---
    @{ Name = "7zip";              Desc = "File archiver (zip, tar, 7z, etc.)" }
    @{ Name = "curl";              Desc = "URL transfer tool" }
)

# ── Mode banner ──────────────────────────────────────────────────────
if ($Check) {
    Write-Header "Windows Dev Environment — Health Check"
    Write-Info "Running in CHECK mode. No changes will be made."
} else {
    Write-Header "Windows Dev Environment — Setup & Update"
}

# ── Chocolatey ───────────────────────────────────────────────────────
Write-Info "Checking for Chocolatey..."
$chocoCmd = Get-Command choco -ErrorAction SilentlyContinue

if ($chocoCmd) {
    $chocoVer = (choco --version 2>$null)
    Write-Ok "Chocolatey $chocoVer installed."
    if (-not $Check) {
        Write-Info "Upgrading Chocolatey itself..."
        choco upgrade chocolatey -y --no-progress | Out-Null
        Write-Ok "Chocolatey updated."
    }
} else {
    if ($Check) {
        Write-Fail "Chocolatey NOT installed. Run without -Check to install."
    } else {
        Write-Info "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        # Refresh PATH so choco is available immediately
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Write-Ok "Chocolatey installed."
    }
}

# Bail if choco still unavailable
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Fail "Chocolatey not available. Cannot continue."
    exit 1
}

# ── Gather outdated packages once ────────────────────────────────────
Write-Info "Checking for outdated packages..."
$outdatedRaw = choco outdated -r 2>$null
$outdatedMap = @{}
foreach ($line in $outdatedRaw) {
    $parts = $line -split '\|'
    if ($parts.Count -ge 3) {
        $outdatedMap[$parts[0]] = @{ Current = $parts[1]; Latest = $parts[2] }
    }
}

# ── Install / Upgrade packages ───────────────────────────────────────
Write-Header "Packages"

foreach ($pkg in $Packages) {
    $name = $pkg.Name
    $desc = $pkg.Desc

    # Check if installed (choco list --local-only is deprecated, use choco list -lo)
    $isInstalled = (choco list $name --local-only --exact -r 2>$null) -match "^$([regex]::Escape($name))\|"

    if ($isInstalled) {
        # Installed — check if outdated
        if ($outdatedMap.ContainsKey($name)) {
            $current = $outdatedMap[$name].Current
            $latest  = $outdatedMap[$name].Latest
            if ($Check) {
                Write-Warn "$name — UPDATE AVAILABLE ($current -> $latest) — $desc"
            } else {
                Write-Info "Upgrading $name ($current -> $latest)..."
                $result = choco upgrade $name -y --no-progress 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Ok "$name upgraded to $latest."
                    $script:Upgraded++
                } else {
                    Write-Fail "Failed to upgrade $name. Continuing..."
                    $script:Failed++
                }
            }
        } else {
            # Get current version
            $verLine = (choco list $name --local-only --exact -r 2>$null) | Select-Object -First 1
            $version = if ($verLine -match '\|(.+)$') { $Matches[1] } else { "installed" }
            Write-Ok "$name $version — up to date ($desc)"
            $script:UpToDate++
        }
    } else {
        # Not installed
        if ($Check) {
            Write-Warn "$name — NOT INSTALLED — $desc"
            $script:Skipped++
        } else {
            Write-Info "Installing $name — $desc"
            $result = choco install $name -y --no-progress 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Ok "$name installed."
                $script:Installed++
            } else {
                Write-Fail "Failed to install $name. Continuing..."
                $script:Failed++
            }
        }
    }
}

# ── Post-install checks ─────────────────────────────────────────────
Write-Header "Environment Health"

# Refresh PATH after installs
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Git
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    $gitVer = (git --version 2>$null)
    Write-Ok "$gitVer ready."
} else {
    Write-Warn "Git not found on PATH. Restart your shell if just installed."
}

# GitHub CLI auth
$ghCmd = Get-Command gh -ErrorAction SilentlyContinue
if ($ghCmd) {
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "GitHub CLI authenticated."
    } else {
        Write-Warn "GitHub CLI installed but NOT authenticated. Run: gh auth login"
    }
}

# Node.js
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $nodeVer = (node --version 2>$null)
    Write-Ok "Node.js $nodeVer ready."
} else {
    Write-Warn "Node.js not found on PATH. Restart your shell if just installed."
}

# Claude Code CLI
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if ($claudeCmd) {
    Write-Ok "Claude Code CLI installed."
} else {
    Write-Warn "Claude Code CLI not installed. Run: npm install -g @anthropic-ai/claude-code"
}

# VSCode
$codeCmd = Get-Command code -ErrorAction SilentlyContinue
if ($codeCmd) {
    Write-Ok "VSCode ready."
} else {
    Write-Warn "VSCode not found on PATH. Restart your shell if just installed."
}

# PowerShell 7
$pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
if ($pwshCmd) {
    $pwshVer = (pwsh --version 2>$null)
    Write-Ok "PowerShell $pwshVer ready."
} else {
    Write-Warn "PowerShell 7 not found. Restart your shell if just installed."
}

# ── Summary ──────────────────────────────────────────────────────────
Write-Header "Summary"

$totalPackages = $Packages.Count

if ($Check) {
    $outdatedCount = $totalPackages - $script:UpToDate - $script:Skipped
    Write-Host "  Up to date:  $($script:UpToDate)" -ForegroundColor Green
    Write-Host "  Outdated:    $outdatedCount" -ForegroundColor Yellow
    Write-Host "  Missing:     $($script:Skipped)" -ForegroundColor Red
    Write-Host ""
    if ($script:Skipped -gt 0 -or $outdatedCount -gt 0) {
        Write-Info "Run without -Check to install missing and upgrade outdated packages."
    } else {
        Write-Ok "Everything is up to date."
    }
} else {
    Write-Host "  Already current:  $($script:UpToDate)" -ForegroundColor Green
    Write-Host "  Newly installed:  $($script:Installed)" -ForegroundColor Green
    Write-Host "  Upgraded:         $($script:Upgraded)" -ForegroundColor Green
    if ($script:Failed -gt 0) {
        Write-Host "  Failed:           $($script:Failed)" -ForegroundColor Red
    }
    Write-Host ""
    Write-Info "Remaining manual steps:"

    $step = 1
    $ghAuth = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  $step. gh auth login                              — Authenticate GitHub CLI"
        $step++
    }
    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
        Write-Host "  $step. npm install -g @anthropic-ai/claude-code   — Install Claude Code CLI"
        $step++
    }
    Write-Host ""
    Write-Ok "You're good to go."
}
