# Package Manager Setup — PAD Flow

Power Automate Desktop flow that sets up your Windows dev environment with Chocolatey. Import and run with one click.

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
3. Runs `choco-setup.ps1` which installs Chocolatey, CLI tools, GUI apps, and checks environment health

---

## Requirements

- Windows 10/11
- Power Automate Desktop
- Git (for initial repo clone)
- Internet connection

---

## See Also

- [PowerShell Script](../../scripts/package-manager-setup/) — run directly from PowerShell
- [Apple Shortcut](../../shortcuts/package-manager-setup/) — macOS equivalent via Shortcuts.app
