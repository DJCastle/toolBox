# App Downloader — PAD Flow

Power Automate Desktop flow that downloads installer files for apps not in the Microsoft Store. Import and run with one click.

---

## Import

1. Open **Power Automate Desktop** > **+ New flow**
2. Name it "Dev Download Apps"
3. Open `Dev-Download-Apps.pad` in a text editor, select all, copy
4. Paste into the PAD flow editor and save

---

## What It Does

1. Checks if `~\Developer\toolBox` exists — clones the repo if not
2. Opens a **PowerShell window**
3. Runs `download-apps.ps1` which downloads installer EXE/MSI files to your Downloads folder

Nothing is installed or opened — files are saved to your Downloads folder.

---

## Requirements

- Windows 10/11
- Power Automate Desktop
- Git (for initial repo clone)
- Internet connection

---

## See Also

- [PowerShell Script](../../scripts/app-downloader/) — run directly from PowerShell
- [Apple Shortcut](../../shortcuts/app-downloader/) — macOS equivalent via Shortcuts.app
