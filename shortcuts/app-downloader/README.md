# App Downloader — Apple Shortcut

Apple Shortcuts version that downloads installer files for apps not in the App Store. Import and run with one click.

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
3. Runs `download-apps.sh` which downloads installer DMGs to your Downloads folder

Nothing is installed or opened — files are saved to your Downloads folder.

---

## Requirements

- macOS 12.0+ (Monterey) — Shortcuts.app required
- Homebrew (for URL resolution)
- Internet connection

---

## See Also

- [Shell Script](../../scripts/app-downloader/) — run directly from Terminal
- [PAD Flow](../../pad-flows/app-downloader/) — Windows equivalent via Power Automate Desktop
