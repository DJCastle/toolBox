# Package Manager Setup — Apple Shortcut

Apple Shortcuts version that sets up your macOS dev environment with Homebrew. Import and run with one click.

---

## Security

This shortcut runs a shell script. Before using it:

1. Open **Shortcuts.app** > **Settings** > **Advanced**
2. Enable **Allow Running Scripts**
3. Run the shortcut
4. **Disable "Allow Running Scripts" when done** — best practice to keep this off when not in use

---

## Import

Double-click **Dev-Brew-Setup.shortcut** to import into Shortcuts.app, or:

1. Open **Shortcuts.app**
2. File > Import...
3. Select `Dev-Brew-Setup.shortcut`

---

## What It Does

1. Checks if `~/Developer/toolBox` exists — clones the repo if not
2. Opens **Terminal.app**
3. Runs `brew-setup.sh` which installs Homebrew, CLI tools, GUI apps, and checks environment health

---

## Requirements

- macOS 12.0+ (Monterey) — Shortcuts.app required
- Internet connection
- Admin password (for Homebrew install on first run)

---

## See Also

- [Shell Script](../../scripts/package-manager-setup/) — run directly from Terminal
- [PAD Flow](../../pad-flows/package-manager-setup/) — Windows equivalent via Power Automate Desktop
