# Toolbox

> A collection of useful macOS and Windows automation tools by [CodeCraftedApps](https://codecraftedapps.com).

Automator apps, shell scripts, PowerShell scripts, Apple Shortcuts, and Power Automate Desktop flows — organized by type. Each tool has its own folder with documentation. Browse by category below, or jump straight to a specific tool.

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)](https://www.apple.com/macos/)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D4)](https://www.microsoft.com/windows)
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-native-green)](https://support.apple.com/en-us/116943)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Website](https://img.shields.io/badge/Website-toolbox.codecraftedapps.com-007AFF)](https://toolbox.codecraftedapps.com)

---

## Categories

| Category | Platforms | Description |
| -------- | --------- | ----------- |
| [automator](automator/) | macOS | Native apps built with AppleScript and compiled into `.app` bundles |
| [scripts](scripts/) | macOS, Windows | Command-line shell scripts and PowerShell scripts |
| [shortcuts](shortcuts/) | macOS | Apple Shortcuts — import into Shortcuts.app and run with one click |
| [pad-flows](pad-flows/) | Windows | Power Automate Desktop flows — import and run with one click |

---

## What's Inside

| Tool | Script | Shortcut / PAD | Description |
| ---- | :----: | :------------: | ----------- |
| **Non App Store Apps Download** | [macOS](scripts/non-appstore-download/) | [Shortcut](shortcuts/non-appstore-download/) | Batch download apps like Chrome, VS Code, and Slack from official sources. Also available as an [Automator app](automator/non-appstore-download/). |
| **Package Manager Setup** | [macOS](scripts/package-manager-setup/) · [Windows](scripts/package-manager-setup/) | [Shortcut](shortcuts/package-manager-setup/) · [PAD](pad-flows/package-manager-setup/) | Bootstrap a dev environment with Homebrew (macOS) or Chocolatey (Windows) |
| **Repo Sync** | [macOS](scripts/repo-sync/) · [Windows](scripts/repo-sync/) | [Shortcut](shortcuts/repo-sync/) · [PAD](pad-flows/repo-sync/) | Clone and update all your GitHub repos into ~/Developer |
| **App Downloader** | [macOS](scripts/app-downloader/) · [Windows](scripts/app-downloader/) | [Shortcut](shortcuts/app-downloader/) · [PAD](pad-flows/app-downloader/) | Download app installers to your Downloads folder with version tracking |

---

## How This Repo Is Organized

```text
├── automator/                             # macOS native apps
│   └── non-appstore-download/
│
├── scripts/                               # Shell + PowerShell scripts
│   ├── non-appstore-download/             #   macOS only
│   ├── package-manager-setup/             #   macOS + Windows
│   ├── repo-sync/                         #   macOS + Windows
│   └── app-downloader/                    #   macOS + Windows
│
├── shortcuts/                             # macOS Apple Shortcuts
│   ├── non-appstore-download/
│   ├── package-manager-setup/
│   ├── repo-sync/
│   └── app-downloader/
│
├── pad-flows/                             # Windows Power Automate Desktop
│   ├── package-manager-setup/
│   ├── repo-sync/
│   └── app-downloader/
│
├── DISCLAIMER.md
├── LICENSE
└── README.md                              # This file
```

**Adding new tools:** Create a new folder under the appropriate category with its own `README.md`. If the tool doesn't fit an existing category, create a new top-level folder.

---

## Security

Tools in this collection serve different purposes — please understand what each one does before running it:

- **Download-only tools** (Non App Store Apps Download, App Downloader) download installer files but do **not** install, modify, or execute anything. Downloads resolve to official vendor URLs via [Homebrew Cask](https://formulae.brew.sh/cask/) or trusted vendor sites.
- **Package manager tools** (Package Manager Setup) install software packages via [Homebrew](https://brew.sh/) or [Chocolatey](https://chocolatey.org/). Review the package lists in the scripts before running.
- **Repo sync tools** (Repo Sync) clone and pull Git repositories. No files are modified — only standard `git clone` and `git pull` operations.

**Apple Shortcuts** require enabling "Allow Running Scripts" in Shortcuts settings. Disable this after use.

**PAD Flows** run PowerShell scripts. Review the `.pad` files in a text editor before importing.

See [DISCLAIMER.md](DISCLAIMER.md) for the full disclaimer.

---

## License

[MIT License](LICENSE) — free to use, modify, and distribute.

---

## Links

- **Website:** [toolbox.codecraftedapps.com](https://toolbox.codecraftedapps.com)
- **GitHub:** [github.com/DJCastle/toolBox](https://github.com/DJCastle/toolBox)
- **CodeCraftedApps:** [codecraftedapps.com](https://codecraftedapps.com)
