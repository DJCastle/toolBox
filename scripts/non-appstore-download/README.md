# Non App Store Apps Download — Shell Script

Standalone command-line tool that batch downloads non-App Store apps to your Desktop. One command, no GUI required. Resolves the latest stable release of each app via the [Homebrew Cask API](https://formulae.brew.sh/cask/).

---

## Usage

```bash
bash download-apps.sh
```

Downloads all apps to `~/Desktop` with color-coded status:

- **[downloading]** — in progress
- **[done]** — saved to Desktop
- **[failed]** — download error

---

## How It Works

1. For each app, queries the Homebrew Cask API (`https://formulae.brew.sh/api/cask/<name>.json`) to resolve the latest official download URL
2. Downloads each file to `~/Desktop` with `curl`
3. Shows color-coded status for each app

No Homebrew installation required — only uses the public API for URL resolution.

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

## Customization

To add or remove apps, edit the `brew_download` calls at the bottom of `download-apps.sh`:

```bash
# Add a new app — use the Homebrew cask name
brew_download "App Display Name" "cask-name"

# Example: add Firefox
brew_download "Firefox" "firefox"
```

Find cask names at [formulae.brew.sh/cask](https://formulae.brew.sh/cask/).

---

## Requirements

- macOS (any recent version)
- Internet connection
- Python 3 (included with macOS)

---

## Verifying Downloads

After downloading, verify each installer's code signature before running it:

```bash
# Check if the app is signed by an identified developer
spctl --assess --verbose /path/to/App.app

# Show detailed signature info
codesign --verify --deep --verbose /path/to/App.app
```

---

## See Also

- [App Downloader](../app-downloader/) — newer version with `--check` mode, version tracking, and Windows support
- [AppleScript App](../../automator/non-appstore-download/) — full GUI with app search and management
- [Apple Shortcut](../../shortcuts/non-appstore-download/) — run from Shortcuts.app
