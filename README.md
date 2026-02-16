# Non App Store Apps Download

> Part of [Shortcuts Collection](https://appleshortcuts.codecraftedapps.com) — curated macOS automation tools by CodeCraftedApps.

Many essential Mac apps — like Chrome, VS Code, and Slack — aren't available in the Apple App Store. Every time you reinstall macOS, you visit a dozen vendor websites to download them all over again. This native macOS AppleScript application does it for you: search by name, build your list, and batch download the latest stable releases from official sources in one click. Built with [Apple's macOS automation technologies](https://support.apple.com/guide/automator/welcome/mac).

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)](https://www.apple.com/macos/)
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-native-green)](https://support.apple.com/en-us/116943)
[![AppleScript](https://img.shields.io/badge/Built%20with-AppleScript-blueviolet)](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Website](https://img.shields.io/badge/Website-appleshortcuts.codecraftedapps.com-007AFF)](https://appleshortcuts.codecraftedapps.com)

---

## Important — Use With Care

This tool is for apps that are **not available in the Apple App Store**. If an app is in the App Store, use the App Store — it's the safest and easiest way to install software on your Mac.

This tool **only downloads** installer files to your Desktop for apps you'd otherwise have to get from vendor websites. It does **not install, open, or run** anything. You are in full control of what happens after the download.

Please use this responsibly:

- **Know what you're adding.** When searching for apps, make sure you select the correct one. Verify the app name and developer before adding it to your list.
- **Only download software you trust.** Don't add apps you're unfamiliar with. If you're unsure about an app, research it first.
- **Downloads come from official sources.** The BREW: resolver uses Homebrew's community-curated database of official vendor URLs. Direct URLs should always point to the vendor's own website.
- **macOS Gatekeeper is your safety net.** Downloaded apps are verified by macOS before they can run. Keep Gatekeeper enabled.

See [DISCLAIMER.md](DISCLAIMER.md) for full details.

---

## What It Does

Many popular macOS applications — like Chrome, VS Code, Slack, and iTerm2 — are not available in the Apple App Store. You have to download them directly from each vendor's website. This tool automates that process. Great for:

- **System reloads** — get all your essential apps back quickly after a fresh macOS install
- **Keeping local copies** — maintain up-to-date installer files for offline use or multiple machines
- **Batch downloading** — grab everything at once instead of visiting a dozen websites

The app always resolves the **latest stable release** via Homebrew Cask before downloading — no beta or pre-release versions.

**Default Apps:**

| App | Source | Format |
| --- | ------ | ------ |
| Google Chrome | Homebrew Cask | `.dmg` |
| Brave Browser | Homebrew Cask | `.dmg` |
| Visual Studio Code | Homebrew Cask | `.zip` |
| Slack | Homebrew Cask | `.dmg` |
| iTerm2 | Homebrew Cask | `.zip` |

All downloads target **Apple Silicon (ARM64)** natively.

---

## Built With Apple's Automation Technologies

This is a native macOS application built with [AppleScript](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html) and compiled using Apple's `osacompile` tool into a standard `.app` bundle. It uses macOS native dialogs, progress bars, and system integration — no third-party frameworks or runtimes required.

- **AppleScript** — Apple's built-in scripting language for macOS automation ([Apple Documentation](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html))
- **osacompile** — Apple's compiler that builds AppleScript into native macOS applications ([Apple Developer](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptX/Concepts/osa.html))
- **macOS Automation** — Part of Apple's automation framework alongside [Automator](https://support.apple.com/guide/automator/welcome/mac) and Shortcuts

The build script automatically installs the app to your **iCloud Drive > Automator** folder (if iCloud Drive is enabled), keeping it alongside your other macOS automation tools and syncing it across all your Macs.

---

## Quick Start

### Build the App

```bash
git clone https://github.com/DJCastle/appleshortcuts.git
cd appleshortcuts
./build-automator-app.sh
```

The build script compiles the app and **automatically copies it to your iCloud Drive > Automator folder** (if iCloud Drive is enabled). This means the app syncs across all your Macs and is ready to use after a system reload — no manual setup needed. If iCloud Drive is not available, the app is built in the current directory and you can move it wherever you like.

### Shell Script (Alternative)

If you prefer the terminal:

```bash
./download-apps.sh
```

---

## Managing Your App List

### Add Apps (Built-In Search)

1. Launch the app
2. Click **"Manage Apps"** → **"Add App"**
3. Type any app name (e.g. "Firefox", "Slack", "Spotify")
4. Select the correct app from the search results
5. The app is added permanently and will download every time you run the app

**Be careful when selecting.** Search results may include similarly named apps. Always verify you're choosing the right one before adding it.

### Remove Apps

1. Click **"Manage Apps"** → **"Remove App"**
2. Select the apps you want to remove (hold Command to select multiple)
3. Confirm the removal

Removed apps are deleted from apps.txt and won't download on future runs.

### Manual Editing

You can also edit the app list directly:

1. Right-click **Download Apps.app** → **Show Package Contents**
2. Navigate to **Contents → Resources → apps.txt**
3. Open in any text editor

Each line follows this format:

```text
App Name | filename.dmg | BREW:cask-name
```

### Download Sources

| Source | Format | Best For |
| ------ | ------ | -------- |
| Homebrew Cask | `BREW:cask-name` | Most apps — always gets the latest stable release |
| GitHub Releases | `GITHUB:owner/repo` | Open-source apps on GitHub |
| Direct URL | `https://...` | Anything not in Homebrew or GitHub |

Browse available cask names at [formulae.brew.sh/cask](https://formulae.brew.sh/cask/).

---

## How Downloads Work

1. The app resolves the **latest stable release** of each app via Homebrew Cask
2. Files are downloaded to your **Desktop** with a progress bar showing size and speed
3. **Nothing is installed or opened** — the files just sit on your Desktop
4. Open `.dmg` files to mount and install, or unzip `.zip` files to get the `.app`
5. macOS Gatekeeper verifies the code signature before any app can run

### Persistence

Apps you add through the built-in search are **saved permanently**. Close the app and reopen it — your list is still there. Removed apps are deleted from the list and won't download on future runs.

### iCloud Sync (Automatic)

The build script automatically installs the app to your **iCloud Drive > Automator** folder (`~/Library/Mobile Documents/com~apple~Automator/Documents/`). Your customized app list is stored inside the app bundle, so it syncs automatically via iCloud across all your Macs. After a fresh macOS install or on a new Mac, just open the app from iCloud and download everything in one click — no setup needed.

If iCloud Drive is not enabled, the build script will let you know and you can manually move the app to any iCloud-synced folder.

### System Permissions

On first run, macOS may ask you to grant access to:

- **Desktop folder** — where downloaded files are saved
- **Internet / Network** — to resolve latest versions and download from vendor servers
- **File system** — to read and save the app list inside the app bundle

These are standard macOS security prompts. You can review or revoke permissions at any time in **System Settings > Privacy & Security**.

---

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon (M1/M2/M3/M4) — download URLs target ARM64
- Internet connection
- Python 3 (included with macOS)

---

## Security

- **Download only.** This tool downloads files to your Desktop. It does not install, modify, or execute anything.
- **Official sources.** BREW: resolves to vendor URLs curated by the [Homebrew community](https://github.com/Homebrew/homebrew-cask). Direct URLs should always come from the app vendor's official website.
- **Gatekeeper verified.** macOS verifies code signatures before allowing downloaded apps to run.
- **No data collection.** This tool does not collect, store, or transmit any personal data.
- **Open source.** Read every line of code. The entire source is in this repository.

See [DISCLAIMER.md](DISCLAIMER.md) for the full disclaimer.

---

## Project Structure

```text
├── DownloadApps.applescript   # Main app source (AppleScript — Apple's macOS scripting language)
├── apps.txt                    # Editable app list (bundled into .app)
├── build-automator-app.sh      # Build script (uses Apple's osacompile, auto-installs to iCloud)
├── download-apps.sh            # Standalone shell script alternative
├── (gh-pages branch)            # Website (GitHub Pages)
├── DISCLAIMER.md               # Third-party software disclaimer
├── LICENSE                     # MIT License
└── README.md                   # This file
```

---

## License

[MIT License](LICENSE) — free to use, modify, and distribute.

---

## Links

- **Website:** [appleshortcuts.codecraftedapps.com](https://appleshortcuts.codecraftedapps.com)
- **GitHub:** [github.com/DJCastle/appleshortcuts](https://github.com/DJCastle/appleshortcuts)
- **CodeCraftedApps:** [codecraftedapps.com](https://codecraftedapps.com)
