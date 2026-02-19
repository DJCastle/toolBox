# Package Manager Setup — PAD Flow

Power Automate Desktop flow that sets up your Windows dev environment with Chocolatey. Import and run with one click — the flow launches an elevated PowerShell window and runs the script from this repo.

---

## Import

1. Open **Power Automate Desktop** > **+ New flow**
2. Name it "Dev Choco Setup"
3. Open `Dev-Choco-Setup.pad` in a text editor, select all, copy
4. Paste into the PAD flow editor and save

---

## What It Does

1. Checks if `~\Developer\toolBox` exists — clones the repo if not
2. Opens an **elevated PowerShell window** (UAC prompt) because Chocolatey requires administrator privileges
3. Runs [`choco-setup.ps1`](../../scripts/package-manager-setup/choco-setup.ps1) which:
   - Installs or updates Chocolatey package manager
   - Installs/upgrades CLI tools and GUI apps
   - Checks environment health (git, gh auth, node, VSCode, PowerShell 7)
   - Prints a summary with remaining manual steps

---

## Default Packages

The script installs these packages by default:

| Package | Description |
| ------- | ----------- |
| git | Git version control |
| gh | GitHub CLI |
| nodejs-lts | Node.js LTS runtime |
| python3 | Python 3 runtime |
| jq | JSON processor |
| wget | File downloader |
| vscode | Visual Studio Code |
| microsoft-windows-terminal | Windows Terminal |
| powershell-core | PowerShell 7+ |
| 7zip | File archiver |
| curl | URL transfer tool |

---

## Customization

This flow runs the script from the repo, so to change the package list:

1. Open `scripts\package-manager-setup\choco-setup.ps1` in a text editor
2. Edit the `$Packages` array (~line 63)
3. Add entries in this format:

```powershell
@{ Name = "choco-package-id"; Desc = "description" }
```

Find package IDs at [community.chocolatey.org/packages](https://community.chocolatey.org/packages).

---

## Requirements

- Windows 10/11
- Power Automate Desktop (pre-installed on Windows 11, [free download](https://learn.microsoft.com/en-us/power-automate/desktop-flows/install) for Windows 10)
- Git (for initial repo clone)
- Internet connection
- Administrator privileges (UAC prompt on launch)

---

## See Also

- [PowerShell Script](../../scripts/package-manager-setup/) — run directly from PowerShell (also has `-Check` mode)
- [Apple Shortcut](../../shortcuts/package-manager-setup/) — macOS equivalent via Shortcuts.app
