# Shell Scripts

Command-line tools for macOS and Windows. Run from Terminal or PowerShell — no GUI required. Great for automation, scripting, and headless systems.

---

## Getting Started

1. **macOS:** Open **Terminal.app** and `cd` to the `scripts/` folder
2. **Windows:** Open **PowerShell** and `cd` to the `scripts\` folder
3. Pick a script from the table below and follow its README

**Recommended order for a fresh system:**

1. [package-manager-setup](package-manager-setup/) — install Homebrew (macOS) or Chocolatey (Windows) + core dev tools
2. [repo-sync](repo-sync/) — clone all your GitHub repos into `~/Developer`
3. [app-downloader](app-downloader/) — download app installers to your Downloads folder

---

## Prerequisites

**macOS:**

- macOS 13.0+ (Ventura) or later
- Internet connection
- Admin password (for Homebrew install on first run)

**Windows:**

- Windows 10/11
- Internet connection
- Administrator privileges (for Chocolatey)

---

## How to Run

**macOS (bash scripts):**

```bash
bash scripts/<folder>/script-name.sh              # Full run
bash scripts/<folder>/script-name.sh --check      # Report only — no changes
```

**Windows (PowerShell scripts):**

```powershell
.\scripts\<folder>\script-name.ps1                # Full run
.\scripts\<folder>\script-name.ps1 -Check         # Report only — no changes
```

All scripts support a `--check` / `-Check` flag that shows what would happen without making any changes. Safe to run anytime.

---

## Customization

Each script contains an array of packages, apps, or repos near the top of the file. Edit these arrays to match your needs:

- **brew-setup.sh** — `FORMULAE` and `CASKS` arrays (~line 131)
- **choco-setup.ps1** — `$Packages` array (~line 63)
- **download-apps.sh** — `CASK_TOKENS` array (~line 72)
- **download-apps.ps1** — `$Apps` array (~line 109)
- **clone-repos.sh** — `SKIP_REPOS` array (~line 63) and `GITHUB_USER` variable (~line 57)
- **clone-repos.ps1** — `$SkipRepos` array (~line 61) and `$GitHubUser` variable (~line 55)

See each script's README for format details and examples.

---

## Available Scripts

| Script | Platforms | Description |
| ------ | --------- | ----------- |
| [non-appstore-download](non-appstore-download/) | macOS | Batch download non-App Store apps to your Desktop with one command |
| [package-manager-setup](package-manager-setup/) | macOS, Windows | Bootstrap a dev environment with Homebrew or Chocolatey |
| [repo-sync](repo-sync/) | macOS, Windows | Clone and update all your GitHub repos into ~/Developer |
| [app-downloader](app-downloader/) | macOS, Windows | Download app installers to your Downloads folder |
