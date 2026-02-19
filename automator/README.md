# Automator Apps

Native macOS applications built with [AppleScript](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html) and compiled using Apple's `osacompile` into standard `.app` bundles. These use macOS native dialogs, progress bars, and system integration — no third-party frameworks required.

---

## How to Build

Each app folder contains a `build-automator-app.sh` script:

```bash
cd automator/<app-folder>
bash build-automator-app.sh
```

This compiles the AppleScript source into a `.app` bundle. If iCloud Drive is enabled, the app is automatically copied to **iCloud Drive > Automator** for cross-Mac sync.

To run: double-click the built `.app` file.

---

## How It Works

1. **Source:** Each app is written in AppleScript (`.applescript` file)
2. **Build:** Apple's `osacompile` compiles it into a native `.app` bundle
3. **Config:** Supporting files (like `apps.txt`) are bundled into `Contents/Resources/` inside the app
4. **Sync:** The build script copies the app to iCloud Drive so it's available on all your Macs

---

## Requirements

- macOS 13.0+ (Ventura)
- Apple Silicon or Intel
- Internet connection (for downloading apps)
- Python 3 (included with macOS)

---

## Available Apps

| App | Description |
| --- | ----------- |
| [non-appstore-download](non-appstore-download/) | Batch download non-App Store apps (Chrome, VS Code, Slack, etc.) from official sources with a full GUI |
