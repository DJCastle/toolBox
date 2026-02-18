# Toolbox

> A collection of useful macOS automation tools by [CodeCraftedApps](https://codecraftedapps.com).

Automator apps, shell scripts, and Apple Shortcuts for macOS — organized by type. Each tool has its own folder with documentation. Browse by category below, or jump straight to a specific tool.

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)](https://www.apple.com/macos/)
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-native-green)](https://support.apple.com/en-us/116943)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Website](https://img.shields.io/badge/Website-toolbox.codecraftedapps.com-007AFF)](https://toolbox.codecraftedapps.com)

---

## Categories

| Category | Description |
| -------- | ----------- |
| [automator](automator/) | macOS native apps built with AppleScript and compiled into `.app` bundles |
| [scripts](scripts/) | macOS command-line shell scripts — run from Terminal |
| [shortcuts](shortcuts/) | macOS Apple Shortcuts — import into Shortcuts.app and run with one click |

---

## What's Inside

| Tool | Automator | Script | Shortcut |
| ---- | :-------: | :----: | :------: |
| **Non App Store Apps Download** — batch download apps like Chrome, VS Code, and Slack from official sources | [View](automator/non-appstore-download/) | [View](scripts/non-appstore-download/) | [View](shortcuts/non-appstore-download/) |

---

## How This Repo Is Organized

```text
├── automator/                             # macOS native apps
│   └── non-appstore-download/             #   Each tool gets its own folder
│       ├── README.md                      #   with its own documentation
│       └── ...
│
├── scripts/                               # macOS shell scripts
│   └── non-appstore-download/
│       ├── README.md
│       └── ...
│
├── shortcuts/                             # macOS Apple Shortcuts
│   └── non-appstore-download/
│       ├── README.md
│       └── ...
│
├── DISCLAIMER.md
├── LICENSE
└── README.md                              # This file
```

**Adding new tools:** Create a new folder under the appropriate category with its own `README.md`. If the tool doesn't fit an existing category, create a new top-level folder.

---

## Security

All tools in this collection **only download files** — nothing is installed, modified, or executed. Downloads resolve to official vendor URLs via [Homebrew Cask](https://formulae.brew.sh/cask/). macOS Gatekeeper verifies code signatures before apps can run.

See [DISCLAIMER.md](DISCLAIMER.md) for the full disclaimer.

---

## License

[MIT License](LICENSE) — free to use, modify, and distribute.

---

## Links

- **Website:** [toolbox.codecraftedapps.com](https://toolbox.codecraftedapps.com)
- **GitHub:** [github.com/DJCastle/toolBox](https://github.com/DJCastle/toolBox)
- **CodeCraftedApps:** [codecraftedapps.com](https://codecraftedapps.com)
