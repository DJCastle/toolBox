# Disclaimer

## About This Application

**Non App Store Apps Download** is a native macOS application built with [AppleScript](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html) and compiled using Apple's `osacompile` tool. It is part of Apple's [macOS automation ecosystem](https://support.apple.com/guide/automator/welcome/mac) and runs as a standard `.app` bundle — no third-party frameworks or runtimes required.

## For Apps Not in the App Store

This tool is designed for applications that are **not available in the Apple App Store** — apps like Chrome, VS Code, Slack, and iTerm2 that require downloading directly from vendor websites. If an app is available in the App Store, use the App Store. It is the safest and easiest way to install software on your Mac.

## Download Only

This is a download utility. It downloads installer files to your Desktop for apps you'd otherwise have to get from vendor websites. It does **not install, open, modify, or execute** any software. What you do with the downloaded files is entirely your responsibility.

## Use With Care

This tool makes it easy to search for and download macOS applications. Please use it responsibly:

- **Verify what you're adding.** When searching for apps, ensure you select the correct one. Search results may include similarly named apps from different developers.
- **Only download software you recognize and trust.** Do not add unfamiliar apps to your list without researching them first.
- **Review apps before installing.** After downloading, verify the developer and application before opening any installer files.

## Third-Party Software

This tool is **not affiliated with, endorsed by, or sponsored by** any of the software vendors whose products it helps download. All application names, logos, and trademarks are the property of their respective owners.

## Download Sources

This tool resolves download URLs from the following trusted sources:

- **Homebrew Cask** (`BREW:`) — A community-maintained, open-source database of official macOS application download URLs. Maintained at [github.com/Homebrew/homebrew-cask](https://github.com/Homebrew/homebrew-cask).
- **GitHub Releases** (`GITHUB:`) — Downloads directly from the developer's GitHub release page.
- **Direct URLs** — User-provided URLs that should always point to the app vendor's official website.

This tool does not host, mirror, redistribute, or modify any third-party software. All downloads are fetched directly from the original publisher's servers.

## Homebrew Cask

This tool uses the [Homebrew Cask](https://formulae.brew.sh/cask/) public API to resolve download URLs. Homebrew is an independent, community-maintained open-source project licensed under the [BSD 2-Clause License](https://github.com/Homebrew/homebrew-cask/blob/master/LICENSE). This tool is not affiliated with or endorsed by the Homebrew project.

## Intended Use

This tool is designed for:

- **System reloads** — Quickly re-downloading essential apps after a fresh macOS install
- **Keeping local copies** — Maintaining up-to-date installer files for offline use or multiple machines
- **Batch downloading** — Saving time by downloading everything at once instead of visiting individual websites

## No Warranty

This software is provided "as is" without warranty of any kind. The authors are not responsible for:

- The content, safety, or functionality of any third-party software downloaded using this tool
- Any changes to download URLs made by third-party vendors or the Homebrew Cask community
- Any damage or data loss resulting from the installation of third-party software
- The availability or uptime of third-party download servers
- Apps selected or downloaded by the user in error

## User Responsibility

By using this tool, you acknowledge that:

- You are responsible for verifying that each app you add is the correct application from a trusted developer
- You are responsible for reviewing and accepting the license agreements of any software you download
- You should verify the integrity of downloaded files before installation
- You assume all risk associated with downloading and installing third-party software
- You will comply with all applicable laws and software license terms

## System Permissions

When you first run the app, macOS may prompt you to grant access to certain system resources. These are standard macOS security prompts and are required for the app to function:

- **Desktop folder** — The app downloads files to your Desktop. macOS requires explicit permission for apps to write to this location.
- **Internet / Network** — The app connects to Homebrew's API to resolve the latest stable release URLs, and then downloads files directly from vendor servers.
- **File system (app bundle)** — The app reads and writes to its own `apps.txt` configuration file inside the app bundle to save your app list between sessions.

These permissions are managed by macOS and can be reviewed or revoked at any time in **System Settings > Privacy & Security**. The app does not access any files, folders, or services beyond what is listed above.

## Persistence

Apps you add through the built-in search are saved permanently to the `apps.txt` file inside the app bundle. Your list persists between sessions — close the app and reopen it, and your apps will still be there. Removing an app deletes it from `apps.txt` so it won't download on future runs.

## iCloud Sync (Automatic)

The build script automatically installs the app to your **iCloud Drive > Automator** folder (`~/Library/Mobile Documents/com~apple~Automator/Documents/`) if iCloud Drive is enabled. Because your app list is stored inside the app bundle, it syncs automatically across all your Macs via iCloud. After a system reload or on a new machine, simply open the app from iCloud — your full app list is ready to go.

If iCloud Drive is not enabled, the app is built in the current directory and you can manually move it to any iCloud-synced folder.

## Code Signature Verification

macOS Gatekeeper will verify the code signature of downloaded applications before allowing them to run. We recommend keeping Gatekeeper enabled and only running applications from identified developers.

## Contact

Questions or concerns? Open an issue on [GitHub](https://github.com/DJCastle/nonappstoreappsdownload/issues) or visit the [CodeCraftedApps Contact page](https://codecraftedapps.com/contact.html).
