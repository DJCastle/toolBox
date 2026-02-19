# Package Manager Setup — Apple Shortcut

Apple Shortcuts version that sets up your macOS dev environment with Homebrew. Import and run with one click — the shortcut launches Terminal and runs the shell script from this repo.

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
3. Runs [`brew-setup.sh`](../../scripts/package-manager-setup/brew-setup.sh) which:
   - Installs Xcode Command Line Tools (if missing)
   - Installs or updates Homebrew
   - Installs/upgrades CLI tools and GUI apps
   - Runs brew cleanup to free disk space
   - Checks environment health (gh auth, node, VSCode, Xcode)
   - Prints a summary with remaining manual steps

---

## Default Packages

The script installs these packages by default:

| Type | Packages |
| ---- | -------- |
| Formulae | gh, swiftlint, xcbeautify, node, jq, tree, wget, cocoapods, fastlane, swiftformat, mas |
| Casks | visual-studio-code |

---

## Customization

This shortcut runs the script from the repo, so to change the package list:

1. Open `scripts/package-manager-setup/brew-setup.sh` in a text editor
2. Edit the `FORMULAE` array (~line 131) for CLI tools
3. Edit the `CASKS` array (~line 200) for GUI apps

Format: `"package-name|description"`

---

## Requirements

- macOS 12.0+ (Monterey) — Shortcuts.app required
- Internet connection
- Admin password (for Homebrew install on first run)

---

## See Also

- [Shell Script](../../scripts/package-manager-setup/) — run directly from Terminal (also has `--check` mode)
- [PAD Flow](../../pad-flows/package-manager-setup/) — Windows equivalent via Power Automate Desktop
