# Repo Sync — PAD Flow

Power Automate Desktop flow that clones and updates all your GitHub repos. Import and run with one click.

---

## Import

1. Open **Power Automate Desktop** > **+ New flow**
2. Name it "Dev Clone Repos"
3. Open `Dev-Clone-Repos.pad` in a text editor, select all, copy
4. Paste into the PAD flow editor and save

---

## What It Does

1. Checks if `~\Developer\toolBox` exists — clones the repo if not
2. Opens a **PowerShell window**
3. Runs `clone-repos.ps1` which presents an interactive menu to choose which repos to sync

---

## Requirements

- Windows 10/11
- Power Automate Desktop
- [gh](https://cli.github.com/) (GitHub CLI) — installed by choco-setup.ps1
- Git (for initial repo clone)
- Internet connection

---

## See Also

- [PowerShell Script](../../scripts/repo-sync/) — run directly from PowerShell
- [Apple Shortcut](../../shortcuts/repo-sync/) — macOS equivalent via Shortcuts.app
