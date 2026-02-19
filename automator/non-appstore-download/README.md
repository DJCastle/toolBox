# Non App Store Apps Download — AppleScript App

Native macOS GUI application that batch downloads non-App Store apps. Search by name, build your list, and download the latest stable releases from official sources in one click.

---

## Important — Use With Care

This tool **only downloads** installer files to your Desktop. It does **not install, open, or run** anything. Only download software you trust. See [DISCLAIMER.md](../../DISCLAIMER.md) for full details.

---

## Quick Start

```bash
./build-automator-app.sh
```

Compiles the app using Apple's `osacompile` and auto-installs to **iCloud Drive > Automator** for cross-Mac sync. Double-click the built app to launch.

---

## Managing Apps

- **Add:** Launch > Manage Apps > Add App > search by name
- **Remove:** Launch > Manage Apps > Remove App > select and confirm
- **Manual edit:** Right-click app > Show Package Contents > Contents > Resources > `apps.txt`

Format: `App Name | filename.dmg | BREW:cask-name`

### Download Sources

| Source | Format | Best For |
| ------ | ------ | -------- |
| Homebrew Cask | `BREW:cask-name` | Most apps — always gets the latest stable release |
| GitHub Releases | `GITHUB:owner/repo` | Open-source apps on GitHub |
| Direct URL | `https://...` | Anything not in Homebrew or GitHub |

Browse cask names at [formulae.brew.sh/cask](https://formulae.brew.sh/cask/).

---

## Default Apps

| App | Cask Name | Format |
| --- | --------- | ------ |
| Google Chrome | `google-chrome` | `.dmg` |
| Brave Browser | `brave-browser` | `.dmg` |
| Visual Studio Code | `visual-studio-code` | `.zip` |
| Slack | `slack` | `.dmg` |
| iTerm2 | `iterm2` | `.zip` |

---

## How It Works

1. Resolves the **latest stable release** of each app via Homebrew Cask
2. Downloads to your **Desktop** with a progress bar showing size and speed
3. **Nothing is installed or opened** — files sit on your Desktop
4. macOS Gatekeeper verifies code signatures before apps can run

### Verifying Downloads

You can manually verify code signatures before installing:

```bash
spctl --assess --verbose /path/to/App.app
codesign --verify --deep --verbose /path/to/App.app
```

macOS Gatekeeper performs this check automatically when you open an app, but manual verification lets you confirm before installation.

### Persistence

Apps you add are **saved permanently** inside the app bundle. Your list persists across sessions.

### iCloud Sync

The build script installs to iCloud Drive > Automator. Your app list syncs automatically across all your Macs.

---

## Requirements

- macOS 13.0+ (Ventura)
- Apple Silicon (M1/M2/M3/M4)
- Internet connection
- Python 3 (included with macOS)

---

## Files

```text
├── DownloadApps.applescript   # Main app source
├── apps.txt                   # Editable app list (bundled into .app)
└── build-automator-app.sh     # Build script
```
