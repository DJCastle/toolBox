# Non App Store Apps Download

> A lightweight macOS utility that downloads popular apps directly from official vendor sources — no App Store required.

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)](https://www.apple.com/macos/)
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-native-green)](https://support.apple.com/en-us/116943)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## What It Does

Downloads macOS applications that aren't available on the App Store — directly from the official vendor servers. No package manager needed, no account required.

**Included Apps:**

| App | Source | Format |
|-----|--------|--------|
| Bambu Studio | GitHub Releases (latest) | `.dmg` |
| Brave Browser | brave.com | `.dmg` |
| Google Chrome | google.com | `.dmg` |
| ChatGPT Desktop | openai.com | `.dmg` |
| Grammarly Desktop | grammarly.com | `.dmg` |
| Visual Studio Code | code.visualstudio.com | `.zip` |

All downloads target **Apple Silicon (ARM64)** natively.

---

## Quick Start

### Option 1: Native macOS App (Recommended)

Build and launch the SwiftUI app — gives you a full GUI with per-download progress bars, speeds, and ETAs.

```bash
git clone https://github.com/DJCastle/nonappstoreappsdownload.git
cd nonappstoreappsdownload
./build.sh
open DownloadApps.app
```

### Option 2: Shell Script

Run the shell script for a simple terminal-based download.

```bash
git clone https://github.com/DJCastle/nonappstoreappsdownload.git
cd nonappstoreappsdownload
./download-apps.sh
```

---

## The App

The native macOS app provides a real-time download dashboard:

- **Per-download progress bars** with live file sizes
- **Download speed** display (MB/s)
- **Estimated time remaining** for each download
- **Parallel downloads** — up to 5 simultaneous (batched automatically)
- **Status indicators** — Queued, Downloading, Complete, Failed
- **Overall progress** bar across all downloads
- **Open Desktop** button when finished

---

## Building from Source

Requires **Xcode Command Line Tools** (macOS 13.0+):

```bash
xcode-select --install   # if not already installed
./build.sh               # compiles DownloadApps.app
```

Or compile manually:

```bash
swiftc -framework SwiftUI -framework AppKit -O \
  -o DownloadApps.app/Contents/MacOS/DownloadApps \
  DownloadApps.swift
```

---

## Customizing the App List

Edit the `appDefinitions` array in `DownloadApps.swift`:

```swift
let appDefinitions: [AppInfo] = [
    AppInfo(name: "Your App", fileName: "YourApp.dmg", urlString: "https://example.com/app.dmg"),
    // ...
]
```

Then rebuild with `./build.sh`.

For the shell script, edit `download-apps.sh` directly.

---

## How Downloads Work

1. All files are downloaded to your **Desktop**
2. `.dmg` files — double-click to mount, drag the app to `/Applications`
3. `.zip` files — unzip to get the `.app`, move to `/Applications`
4. macOS Gatekeeper verifies the code signature automatically on first launch

---

## Requirements

- macOS 13.0 or later
- Apple Silicon (M1/M2/M3/M4)
- Xcode Command Line Tools (for building from source)
- Internet connection

---

## Security

- All downloads come directly from **official vendor servers**
- No software is hosted, mirrored, or modified by this tool
- macOS Gatekeeper verifies code signatures before any app can run
- See [DISCLAIMER.md](DISCLAIMER.md) for full details

---

## License

[MIT License](LICENSE) — free to use, modify, and distribute.

---

Built by [CodeCraftedApps](https://github.com/DJCastle)
