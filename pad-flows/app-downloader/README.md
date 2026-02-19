# App Downloader — PAD Flow

Power Automate Desktop flow that downloads installer files for apps not in the Microsoft Store. Import and run with one click — the flow launches PowerShell and runs the script from this repo.

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
3. Runs [`download-apps.ps1`](../../scripts/app-downloader/download-apps.ps1) which:
   - Downloads EXE/MSI installer files from trusted vendor URLs
   - For GitHub-hosted apps, resolves the latest release dynamically
   - Compares remote file sizes against local to detect updates
   - Shows download progress, speed, and file sizes

Nothing is installed or opened — files are saved to your Downloads folder.

---

## Default Apps

The script downloads these apps by default:

| App | Choco ID |
| --- | -------- |
| Google Chrome | `googlechrome` |
| Brave Browser | `brave` |
| Visual Studio Code | `vscode` |
| Slack | `slack` |

---

## Customization

This flow runs the script from the repo, so to change the app list:

1. Open `scripts\app-downloader\download-apps.ps1` in a text editor
2. Edit the `$Apps` array (~line 109)
3. Add entries in this format:

```powershell
@{
    Name = "Display Name"
    ChocoId = "choco-id"
    Url = "https://direct-download-url"
    FileName = "Setup.exe"
}
```

For GitHub releases, add `Dynamic = $true` and the script resolves the latest URL automatically.

---

## Requirements

- Windows 10/11
- Power Automate Desktop (pre-installed on Windows 11, [free download](https://learn.microsoft.com/en-us/power-automate/desktop-flows/install) for Windows 10)
- Git (for initial repo clone)
- Internet connection

---

## See Also

- [PowerShell Script](../../scripts/app-downloader/) — run directly from PowerShell (also has `-Check` mode)
- [Apple Shortcut](../../shortcuts/app-downloader/) — macOS equivalent via Shortcuts.app
