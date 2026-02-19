<#
.SYNOPSIS
    Windows App Installer Downloader

.DESCRIPTION
    Downloads EXE/MSI installer files for apps that aren't in the Microsoft Store.
    Puts them in ~\Downloads for you to install manually.
    Does NOT install anything — just downloads.

    HOW IT WORKS:
      1. Uses trusted vendor download URLs (sourced from Chocolatey package defs)
      2. For GitHub-hosted apps (Bambu Studio), resolves the latest release dynamically
      3. Compares remote file size against local to detect updates (always gets latest)
      4. Downloads each installer with a progress bar (skips if already up-to-date)
      5. Shows speed, file size, and elapsed time for each download

    ADDING APPS:
      Add a new entry to the $Apps array (~line 52) with:
        @{ Name = "Display Name"; ChocoId = "choco-id"; Url = "https://..."; FileName = "Setup.exe" }
      For GitHub releases, add Dynamic = $true and the script resolves the latest URL.

    APPS INCLUDED:
      - Google Chrome        (googlechrome)
      - Grammarly Desktop    (grammarly-desktop)
      - Bambu Studio         (bambu-studio) — resolved from GitHub releases
      - Brave Browser        (brave)

    REQUIREMENTS:
      - Internet connection
      - Chocolatey (optional, for checking if already installed)

.PARAMETER Check
    Report only — no downloads. Shows what's already downloaded or missing.

.EXAMPLE
    .\download-apps.ps1              Download all apps
    .\download-apps.ps1 -Check       Report only — no downloads
#>

param(
    [switch]$Check
)

$ErrorActionPreference = "Continue"

# ── Config ───────────────────────────────────────────────────────────
$DownloadDir = Join-Path $env:USERPROFILE "Downloads"
$VersionFile = Join-Path $DownloadDir ".download-app-versions"

# ── Output helpers ───────────────────────────────────────────────────
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

# ── Version tracking helpers ─────────────────────────────────────────
# Reads a saved version/size for a given app from the version file.
function Get-SavedVersion {
    param($AppId)
    if (Test-Path $VersionFile) {
        $line = Get-Content $VersionFile | Where-Object { $_ -match "^${AppId}=" }
        if ($line) { return ($line -split '=', 2)[1] }
    }
    return $null
}

# Saves the current version string for an app after a successful download.
function Save-Version {
    param($AppId, $Version)
    if (Test-Path $VersionFile) {
        $lines = Get-Content $VersionFile | Where-Object { $_ -notmatch "^${AppId}=" }
        $lines | Set-Content $VersionFile
    }
    Add-Content -Path $VersionFile -Value "${AppId}=${Version}"
}

# Gets remote file size via HEAD request to detect changes without downloading.
function Get-RemoteFileSize {
    param($Url)
    try {
        $request = [System.Net.WebRequest]::Create($Url)
        $request.Method = "HEAD"
        $request.AllowAutoRedirect = $true
        $request.UserAgent = "PowerShell"
        $request.Timeout = 15000
        $response = $request.GetResponse()
        $size = $response.ContentLength
        $response.Close()
        return $size
    } catch {
        return -1
    }
}

# ── App list ─────────────────────────────────────────────────────────
# Each entry: choco package ID, display name, direct download URL
# URLs sourced from official vendor sites / Chocolatey package defs
# Find choco IDs at: https://community.chocolatey.org/packages
#
# To customize: Edit this array with your preferred apps.
# For GitHub releases, add Dynamic = $true and the script resolves the latest URL.
$Apps = @(
    @{
        Name = "Google Chrome"
        ChocoId = "googlechrome"
        Url = "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi"
        FileName = "GoogleChromeSetup.msi"
    },
    @{
        Name = "Brave Browser"
        ChocoId = "brave"
        Url = "https://laptop-updates.brave.com/latest/winx64"
        FileName = "BraveBrowserSetup.exe"
    },
    @{
        Name = "Visual Studio Code"
        ChocoId = "vscode"
        Url = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"
        FileName = "VSCodeSetup.exe"
    },
    @{
        Name = "Slack"
        ChocoId = "slack"
        Url = "https://slack.com/ssb/download-win64-msi"
        FileName = "SlackSetup.msi"
    }
)

# ── Counters ─────────────────────────────────────────────────────────
$script:Downloaded = 0
$script:Updated    = 0
$script:UpToDate   = 0
$script:Skipped    = 0
$script:Failed     = 0
$Total = $Apps.Count

# ── Preflight ────────────────────────────────────────────────────────
if ($Check) {
    Write-Header "App Downloader — Check Mode"
    Write-Info "Running in CHECK mode. No downloads will be made."
} else {
    Write-Header "App Downloader"
}

# ── Resolve dynamic URLs (GitHub releases) ───────────────────────────
function Get-GitHubLatestAsset {
    param($RepoUrl, $Pattern)
    try {
        # Convert GitHub release page URL to API URL
        $apiUrl = $RepoUrl -replace "github.com/(.+)/releases/latest", "api.github.com/repos/`$1/releases/latest"
        $release = Invoke-RestMethod -Uri $apiUrl -Headers @{ "User-Agent" = "PowerShell" } -ErrorAction Stop
        $asset = $release.assets | Where-Object { $_.name -match $Pattern } | Select-Object -First 1
        if ($asset) {
            return @{ Url = $asset.browser_download_url; FileName = $asset.name }
        }
    } catch {
        return $null
    }
    return $null
}

# ── Process each app ─────────────────────────────────────────────────
Write-Header "Applications"

$current = 0
foreach ($app in $Apps) {
    $current++
    $name = $app.Name
    $url = $app.Url
    $fileName = $app.FileName

    Write-Host "[$current/$Total] $name" -ForegroundColor White

    # Resolve dynamic URLs (e.g., GitHub latest release)
    $resolvedVersion = $null
    if ($app.Dynamic) {
        Write-Info "  Resolving latest release URL..."
        $resolved = Get-GitHubLatestAsset -RepoUrl $url -Pattern "\.exe$"
        if ($resolved) {
            $url = $resolved.Url
            $fileName = $resolved.FileName
            # Extract version from GitHub filename (e.g., "Bambu_Studio_win_v1.9.3.exe" → "v1.9.3")
            if ($fileName -match 'v[\d]+\.[\d]+\.[\d]+') {
                $resolvedVersion = $Matches[0]
            }
            Write-Host "  URL: $url" -ForegroundColor DarkGray
        } else {
            Write-Fail "  Could not resolve download URL for $name"
            $script:Failed++
            Write-Host ""
            continue
        }
    } else {
        Write-Host "  URL: $url" -ForegroundColor DarkGray
    }

    Write-Host "  File: $fileName" -ForegroundColor DarkGray

    # Check if already installed
    $installed = $false
    $chocoCheck = choco list $app.ChocoId --local-only --exact -r 2>$null
    if ($chocoCheck -match $app.ChocoId) {
        Write-Host "  Already installed via Chocolatey" -ForegroundColor Green
        $installed = $true
    }

    $dest = Join-Path $DownloadDir $fileName
    $appId = $app.ChocoId
    $isUpdate = $false

    # Check if already downloaded and whether it's up to date
    if (Test-Path $dest) {
        $localSize = (Get-Item $dest).Length
        $localSizeMB = [math]::Round($localSize / 1MB, 1)
        $savedVer = Get-SavedVersion -AppId $appId

        if ($app.Dynamic -and $resolvedVersion) {
            # GitHub release: compare version strings
            if ($savedVer -and $savedVer -ne $resolvedVersion) {
                $isUpdate = $true
                Write-Host "  Update available: $savedVer -> $resolvedVersion" -ForegroundColor Yellow
            } elseif ($savedVer -eq $resolvedVersion) {
                Write-Host "  Already downloaded ($resolvedVersion) — up to date" -ForegroundColor Green
            } else {
                Write-Host "  Already downloaded ($($localSizeMB)MB)" -ForegroundColor Green
            }
        } else {
            # Vendor URL: compare remote file size to detect changes
            Write-Info "  Checking for updates..."
            $remoteSize = Get-RemoteFileSize -Url $url
            if ($remoteSize -gt 0 -and $remoteSize -ne $localSize) {
                $isUpdate = $true
                $remoteSizeMB = [math]::Round($remoteSize / 1MB, 1)
                Write-Host "  Update available: local $($localSizeMB)MB, remote $($remoteSizeMB)MB" -ForegroundColor Yellow
            } elseif ($remoteSize -gt 0) {
                Write-Host "  Already downloaded ($($localSizeMB)MB) — up to date" -ForegroundColor Green
            } else {
                Write-Host "  Already downloaded ($($localSizeMB)MB) — could not check remote" -ForegroundColor DarkGray
            }
        }

        if ($isUpdate) {
            if ($Check) {
                Write-Warn "$name — update available"
                Write-Host ""
                continue
            }
            $doUpdate = Read-Host "  Download update? [Y/n]"
            if ($doUpdate -match '^[Nn]$') {
                Write-Ok "$name — skipped update"
                $script:Skipped++
                Write-Host ""
                continue
            }
        } else {
            if ($Check) {
                Write-Ok "$name — up to date"
                $script:UpToDate++
                Write-Host ""
                continue
            }
            $redownload = Read-Host "  Re-download anyway? [y/N]"
            if ($redownload -notmatch '^[Yy]$') {
                Write-Ok "$name — skipped (up to date)"
                $script:UpToDate++
                Write-Host ""
                continue
            }
        }
    } else {
        if ($Check) {
            if ($installed) {
                Write-Warn "$name — installed but installer not in Downloads"
            } else {
                Write-Warn "$name — NOT downloaded"
            }
            Write-Host ""
            continue
        }
    }

    # Download with progress
    Write-Host ""
    if ($isUpdate) {
        Write-Info "  Updating $name..."
    } else {
        Write-Info "  Downloading $name..."
    }

    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        # Use BITS for progress on Windows (shows transfer progress natively)
        $webClient = New-Object System.Net.WebClient

        # Register progress event
        $progressChanged = Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
            $percent = $EventArgs.ProgressPercentage
            $received = [math]::Round($EventArgs.BytesReceived / 1MB, 1)
            $total = [math]::Round($EventArgs.TotalBytesToReceive / 1MB, 1)
            Write-Progress -Activity "Downloading" -Status "$received MB / $total MB" -PercentComplete $percent
        }

        $completedEvent = Register-ObjectEvent -InputObject $webClient -EventName DownloadFileCompleted -Action {
            Write-Progress -Activity "Downloading" -Completed
        }

        # Start async download and wait
        $task = $webClient.DownloadFileTaskAsync($url, $dest)
        while (-not $task.IsCompleted) {
            Start-Sleep -Milliseconds 100
        }

        $stopwatch.Stop()

        # Clean up events
        Unregister-Event -SourceIdentifier $progressChanged.Name -ErrorAction SilentlyContinue
        Unregister-Event -SourceIdentifier $completedEvent.Name -ErrorAction SilentlyContinue
        $webClient.Dispose()

        if ($task.IsFaulted) {
            throw $task.Exception.InnerException
        }

        $fileSize = (Get-Item $dest).Length
        $fileSizeMB = [math]::Round($fileSize / 1MB, 1)
        $elapsed = [math]::Round($stopwatch.Elapsed.TotalSeconds, 1)
        $speedMBps = if ($elapsed -gt 0) { [math]::Round($fileSizeMB / $elapsed, 1) } else { "N/A" }

        Write-Host ""
        Write-Host "  Size: $($fileSizeMB)MB | Time: $($elapsed)s | Speed: $($speedMBps) MB/s" -ForegroundColor DarkGray

        # Save version info for future update checks
        $versionTag = if ($resolvedVersion) { $resolvedVersion } else { "$fileSizeMB" }
        Save-Version -AppId $appId -Version $versionTag

        if ($isUpdate) {
            Write-Ok "$name updated → $dest"
            $script:Updated++
        } else {
            Write-Ok "$name downloaded → $dest"
            $script:Downloaded++
        }
    } catch {
        Write-Host ""
        Write-Fail "$name — download failed: $_"
        if (Test-Path $dest) { Remove-Item $dest -Force }
        $script:Failed++
    }

    Write-Host ""
}

# ── Summary ──────────────────────────────────────────────────────────
Write-Header "Summary"

Write-Host "  Download folder:  $DownloadDir" -ForegroundColor Blue
Write-Host ""

if ($Check) {
    Write-Host "  Up to date:     $($script:UpToDate)" -ForegroundColor Green
    Write-Host "  Not downloaded: $($Total - $script:UpToDate)" -ForegroundColor Yellow
    Write-Host ""
    Write-Info "Run without -Check to download."
} else {
    Write-Host "  Downloaded:     $($script:Downloaded)" -ForegroundColor Green
    if ($script:Updated -gt 0) {
        Write-Host "  Updated:        $($script:Updated)" -ForegroundColor Cyan
    }
    Write-Host "  Up to date:     $($script:UpToDate)" -ForegroundColor Green
    Write-Host "  Skipped:        $($script:Skipped)" -ForegroundColor Yellow
    if ($script:Failed -gt 0) {
        Write-Host "  Failed:         $($script:Failed)" -ForegroundColor Red
    }
    Write-Host ""
    if ($script:Downloaded -gt 0 -or $script:Updated -gt 0 -or $script:Skipped -gt 0) {
        Write-Info "Installers are in $DownloadDir"
        Write-Info "Run each installer to complete setup."
    }
}

Write-Host ""
Write-Ok "Done."
