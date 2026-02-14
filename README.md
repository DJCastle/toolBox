# Non App Store Apps Download

> A simple macOS Automator app that downloads popular applications directly from official vendor sources — no App Store required. Easy to customize with your own apps.

[![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue)](https://www.apple.com/macos/)
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-native-green)](https://support.apple.com/en-us/116943)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Website](https://img.shields.io/badge/Website-nonappstoreapps.codecraftedapps.com-10b981)](https://nonappstoreapps.codecraftedapps.com)

---

## What It Does

Downloads macOS applications that aren't on the App Store — directly from the official vendor servers. No package manager needed, no account required. Files are saved to your **Desktop**.

**Default Apps:**

| App | Source | Format |
| --- | ------ | ------ |
| Bambu Studio | GitHub Releases (latest) | `.dmg` |
| Brave Browser | brave.com | `.dmg` |
| Google Chrome | google.com | `.dmg` |
| ChatGPT Desktop | openai.com | `.dmg` |
| Grammarly Desktop | grammarly.com | `.dmg` |
| Visual Studio Code | code.visualstudio.com | `.zip` |

All downloads target **Apple Silicon (ARM64)** natively.

---

## Quick Start

### Automator App (Recommended)

Build the app, double-click to run. Shows a dialog when downloads finish.

```bash
git clone https://github.com/DJCastle/nonappstoreappsdownload.git
cd nonappstoreappsdownload
./build-automator-app.sh
open "Download Apps.app"
```

### Shell Script

If you prefer the terminal:

```bash
git clone https://github.com/DJCastle/nonappstoreappsdownload.git
cd nonappstoreappsdownload
./download-apps.sh
```

---

## Customizing the App List

The whole point of this tool is to make it yours. Add or remove apps using any of these methods:

### Edit in Automator

1. Right-click **Download Apps.app** → **Open With** → **Automator**
2. You'll see the shell script with all the download URLs
3. Add or remove `download` lines:

   ```bash
   download "App Name" "https://example.com/direct-download-link.dmg" "FileName.dmg"
   ```

4. Save (Cmd+S) and close Automator

### Edit the Build Script

1. Open `build-automator-app.sh` in any text editor
2. Find the `APP LIST` section
3. Add or remove `download` lines
4. Run `./build-automator-app.sh` to rebuild

### Edit the Shell Script

Edit `download-apps.sh` directly and run it from Terminal.

---

## How Downloads Work

1. All files are downloaded to your **Desktop**
2. `.dmg` files — double-click to mount, drag the app to `/Applications`
3. `.zip` files — unzip to get the `.app`, move to `/Applications`
4. macOS Gatekeeper verifies the code signature automatically on first launch

---

## Requirements

- macOS 12.0 (Monterey) or later
- Apple Silicon (M1/M2/M3/M4) — download URLs target ARM64
- Internet connection

---

## Security

- All downloads come directly from **official vendor servers**
- No software is hosted, mirrored, or modified by this tool
- macOS Gatekeeper verifies code signatures before any app can run
- See [DISCLAIMER.md](DISCLAIMER.md) for full details

---

## Project Structure

```
├── build-automator-app.sh   # Builds the Automator .app
├── download-apps.sh          # Standalone shell script alternative
├── docs/                     # Website (GitHub Pages)
├── DISCLAIMER.md             # Third-party software disclaimer
├── LICENSE                   # MIT License
└── README.md                 # This file
```

---

## License

[MIT License](LICENSE) — free to use, modify, and distribute.

---

## Links

- **Website:** [nonappstoreapps.codecraftedapps.com](https://nonappstoreapps.codecraftedapps.com)
- **GitHub:** [github.com/DJCastle/nonappstoreappsdownload](https://github.com/DJCastle/nonappstoreappsdownload)
- **CodeCraftedApps:** [codecraftedapps.com](https://codecraftedapps.com)
