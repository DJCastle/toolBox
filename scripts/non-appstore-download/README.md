# Non App Store Apps Download — Shell Script

Standalone command-line tool that batch downloads non-App Store apps to your Desktop. One command, no GUI required.

---

## Usage

```bash
./download-apps.sh
```

Downloads all apps to `~/Desktop` with color-coded status:

- **[downloading]** — in progress
- **[done]** — saved to Desktop
- **[failed]** — download error

---

## How It Works

Resolves each app's latest stable release via the [Homebrew Cask API](https://formulae.brew.sh/cask/) and downloads with `curl`. No Homebrew installation required.

---

## Default Apps

| App | Cask Name |
| --- | --------- |
| Google Chrome | `google-chrome` |
| Brave Browser | `brave-browser` |
| Visual Studio Code | `visual-studio-code` |
| Slack | `slack` |
| iTerm2 | `iterm2` |

To change the list, edit the `brew_download` calls at the bottom of the script.

---

## Requirements

- macOS (any recent version)
- Internet connection
- Python 3 (included with macOS)

---

## See Also

- [AppleScript App](../../automator/non-appstore-download/) — full GUI with app search and management
- [Apple Shortcut](../../shortcuts/non-appstore-download/) — run from Shortcuts.app
