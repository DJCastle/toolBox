# Repo Sync — Apple Shortcut

Apple Shortcuts version that clones and updates all your GitHub repos. Import and run with one click.

---

## Security

This shortcut runs a shell script. Before using it:

1. Open **Shortcuts.app** > **Settings** > **Advanced**
2. Enable **Allow Running Scripts**
3. Run the shortcut
4. **Disable "Allow Running Scripts" when done** — best practice to keep this off when not in use

---

## Import

Double-click **Dev-Clone-Repos.shortcut** to import into Shortcuts.app, or:

1. Open **Shortcuts.app**
2. File > Import...
3. Select `Dev-Clone-Repos.shortcut`

---

## What It Does

1. Checks if `~/Developer/toolBox` exists — clones the repo if not
2. Opens **Terminal.app**
3. Runs `clone-repos.sh` which presents an interactive menu to choose which repos to sync

---

## Requirements

- macOS 12.0+ (Monterey) — Shortcuts.app required
- [gh](https://cli.github.com/) (GitHub CLI) — installed by brew-setup.sh
- Internet connection

---

## See Also

- [Shell Script](../../scripts/repo-sync/) — run directly from Terminal
- [PAD Flow](../../pad-flows/repo-sync/) — Windows equivalent via Power Automate Desktop
