# Package Manager Setup — Shell Scripts

Cross-platform scripts to bootstrap a dev environment from scratch. Installs a package manager, CLI tools, GUI apps, and verifies everything is healthy. Idempotent — safe to run as often as you like.

---

## macOS — `brew-setup.sh`

```bash
bash brew-setup.sh              # Full install + upgrade everything
bash brew-setup.sh --check      # Report only — no changes made
```

Installs Xcode Command Line Tools, Homebrew, CLI formulae (gh, node, swiftlint, etc.), GUI casks (VSCode), and checks environment health.

### Default Packages

| Type | Packages |
| ---- | -------- |
| Formulae | gh, swiftlint, xcbeautify, node, jq, tree, wget, cocoapods, fastlane, swiftformat, mas |
| Casks | visual-studio-code |

### Customization

- **CLI tools:** Add to the `FORMULAE` array as `"name\|description"`
- **GUI apps:** Add to the `CASKS` array as `"name\|description"`

### Requirements

- macOS (Apple Silicon or Intel)
- Internet connection
- Admin password (first run only)

---

## Windows — `choco-setup.ps1`

```powershell
.\choco-setup.ps1               # Full install + upgrade everything (run as Admin)
.\choco-setup.ps1 -Check        # Report only — no changes made
```

Installs Chocolatey, CLI tools (git, gh, node, python, jq, etc.), GUI apps (VSCode, Windows Terminal), and checks environment health.

### Default Packages

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

### Customization

Add to the `$Packages` array as `@{ Name = "choco-id"; Desc = "description" }`.

### Requirements

- Windows 10/11
- Must run as Administrator
- Internet connection

---

## See Also

- [Apple Shortcut](../../shortcuts/package-manager-setup/) — run the macOS script from Shortcuts.app
- [PAD Flow](../../pad-flows/package-manager-setup/) — run the Windows script from Power Automate Desktop
