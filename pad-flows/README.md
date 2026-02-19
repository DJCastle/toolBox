# Power Automate Desktop Flows

One-click launchers for Windows using [Microsoft Power Automate Desktop](https://learn.microsoft.com/en-us/power-automate/desktop-flows/introduction). Each flow runs a PowerShell script from this repo — no coding required.

---

## Available Flows

| Flow | Description |
| ---- | ----------- |
| [package-manager-setup](package-manager-setup/) | Set up a Windows dev environment with Chocolatey |
| [repo-sync](repo-sync/) | Clone and update all your GitHub repos |
| [app-downloader](app-downloader/) | Download app installers to your Downloads folder |

---

## How to Import

1. Open **Power Automate Desktop**
2. Click **+ New flow**
3. Name it (e.g., "Dev Choco Setup")
4. In the flow editor, open the `.pad` file from this repo in a text editor
5. Select all, copy, and paste into the PAD flow editor
6. Save the flow

---

## How to Run

1. Open **Power Automate Desktop**
2. Click the flow name
3. Click **Run**

Each flow will:
- Check if `~/Developer/toolBox` exists — clone the repo if not
- Open a PowerShell window and run the corresponding script

---

## Security

- **Review before running.** Open each `.pad` file in a text editor to see exactly what it does before importing.
- **Delete when done.** PAD flows stay in your account. Remove them after use if you don't need them again.
- The Choco Setup flow requests **administrator privileges** (UAC prompt) because Chocolatey requires elevation.

---

## Requirements

- Windows 10/11
- Power Automate Desktop (pre-installed on Windows 11, [free download](https://learn.microsoft.com/en-us/power-automate/desktop-flows/install) for Windows 10)
- Git (for initial repo clone)
