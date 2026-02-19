# App Downloader — Shell Scripts

Cross-platform scripts that download installer files for apps not in the App Store / Microsoft Store. Saves them to your Downloads folder for manual installation. Does **not** install anything.

---

## macOS — `download-apps.sh`

```bash
bash download-apps.sh              # Download all apps
bash download-apps.sh --check      # Report only — no downloads
```

Resolves each app's latest stable release via the [Homebrew Cask API](https://formulae.brew.sh/cask/) and downloads with `curl`. No Homebrew installation required — only uses the API for URL resolution.

## Windows — `download-apps.ps1`

```powershell
.\download-apps.ps1                # Download all apps
.\download-apps.ps1 -Check         # Report only — no downloads
```

Uses trusted vendor download URLs (sourced from Chocolatey package definitions). For GitHub-hosted apps, resolves the latest release dynamically.

---

## Default Apps

| App | macOS (cask) | Windows (choco) |
| --- | ------------ | --------------- |
| Google Chrome | `google-chrome` | `googlechrome` |
| Brave Browser | `brave-browser` | `brave` |
| Visual Studio Code | `visual-studio-code` | `vscode` |
| Slack | `slack` | `slack` |

---

## Version Tracking

Both scripts track downloaded versions in a `.download-app-versions` file in your Downloads folder. On each run they compare the remote version against the saved version to detect updates:

- **macOS:** Compares Homebrew cask version strings
- **Windows:** Uses HTTP HEAD Content-Length comparison for vendor URLs, GitHub release version strings for dynamic apps

When an update is detected, you'll see: `Update available: v1.2 → v1.3`

---

## Customization

**macOS:** Edit the `CASK_TOKENS` array. Find cask names at [formulae.brew.sh/cask](https://formulae.brew.sh/cask/).

**Windows:** Edit the `$Apps` array with `@{ Name = "Display Name"; ChocoId = "choco-id"; Url = "https://..."; FileName = "Setup.exe" }`. For GitHub releases, add `Dynamic = $true`.

---

## Requirements

**macOS:**
- Homebrew (for URL resolution only)
- jq — installed by brew-setup.sh
- Internet connection

**Windows:**
- Internet connection
- Chocolatey (optional, for checking if already installed)

---

## See Also

- [Apple Shortcut](../../shortcuts/app-downloader/) — run the macOS script from Shortcuts.app
- [PAD Flow](../../pad-flows/app-downloader/) — run the Windows script from Power Automate Desktop
