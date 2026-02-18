# Non App Store Apps Download — Apple Shortcut

Apple Shortcuts version that batch downloads non-App Store apps. Import and run with one click.

---

## Import

Double-click **DownloadApps.shortcut** to import into Shortcuts.app, or:

1. Open **Shortcuts.app**
2. File > Import...
3. Select `DownloadApps.shortcut`

---

## What It Does

1. Resolves the latest stable release of each app via the [Homebrew Cask API](https://formulae.brew.sh/cask/)
2. Downloads each file to your **Desktop**
3. Shows a summary with version numbers and file sizes

Nothing is installed or opened — files are saved to your Desktop.

---

## Default Apps

| App | Cask Name |
| --- | --------- |
| Google Chrome | `google-chrome` |
| Brave Browser | `brave-browser` |
| Visual Studio Code | `visual-studio-code` |
| Slack | `slack` |
| iTerm2 | `iterm2` |

---

## Editing the App List

1. Open **Shortcuts.app**
2. Right-click the shortcut > **Edit**
3. Find the **Run Shell Script** action
4. Edit the `APPS=()` array to add or remove cask names

Find cask names at [formulae.brew.sh/cask](https://formulae.brew.sh/cask/).

---

## Requirements

- macOS 12.0+ (Monterey) — Shortcuts.app required
- Internet connection
- Python 3 (included with macOS)

---

## See Also

- [AppleScript App](../../automator/non-appstore-download/) — full GUI with app search and management
- [Shell Script](../../scripts/non-appstore-download/) — standalone CLI alternative
