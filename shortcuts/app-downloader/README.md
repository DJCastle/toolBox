# App Downloader — Apple Shortcut

Apple Shortcuts version that downloads installer files for apps not in the App Store. Import and run with one click — the shortcut launches Terminal and runs the shell script from this repo.

---

## Security

This shortcut runs a shell script. Before using it:

1. Open **Shortcuts.app** > **Settings** > **Advanced**
2. Enable **Allow Running Scripts**
3. Run the shortcut
4. **Disable "Allow Running Scripts" when done** — best practice to keep this off when not in use

---

## Import

Double-click **Dev-Download-Apps.shortcut** to import into Shortcuts.app, or:

1. Open **Shortcuts.app**
2. File > Import...
3. Select `Dev-Download-Apps.shortcut`

---

## What It Does

1. Checks if `~/Developer/toolBox` exists — clones the repo if not
2. Opens **Terminal.app**
3. Runs [`download-apps.sh`](../../scripts/app-downloader/download-apps.sh) which:
   - Queries Homebrew cask definitions for the latest download URLs
   - Compares remote versions against a local version file to detect updates
   - Downloads each DMG/ZIP installer to `~/Downloads` with a progress bar
   - Shows speed, file size, and elapsed time for each download

Nothing is installed or opened — files are saved to your Downloads folder.

---

## Default Apps

The script downloads these apps by default:

| App | Cask Name |
| --- | --------- |
| Google Chrome | `google-chrome` |
| Brave Browser | `brave-browser` |
| Visual Studio Code | `visual-studio-code` |
| Slack | `slack` |

---

## Customization

This shortcut runs the script from the repo, so to change the app list:

1. Open `scripts/app-downloader/download-apps.sh` in a text editor
2. Edit the `CASK_TOKENS` array (~line 72)
3. Add or remove cask names

Find cask names at [formulae.brew.sh/cask](https://formulae.brew.sh/cask/).

---

## Requirements

- macOS 12.0+ (Monterey) — Shortcuts.app required
- Homebrew (for URL resolution) — installed by [brew-setup.sh](../../scripts/package-manager-setup/)
- jq — installed by brew-setup.sh
- Internet connection

---

## See Also

- [Shell Script](../../scripts/app-downloader/) — run directly from Terminal (also has `--check` mode)
- [PAD Flow](../../pad-flows/app-downloader/) — Windows equivalent via Power Automate Desktop
