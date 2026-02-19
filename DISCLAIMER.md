# Disclaimer

## About This Collection

**Toolbox** is a collection of macOS and Windows automation tools by [CodeCraftedApps](https://codecraftedapps.com). It includes shell scripts, PowerShell scripts, AppleScript applications, Apple Shortcuts, and Power Automate Desktop flows. All tools are open-source under the [MIT License](LICENSE).

## What These Tools Do

This collection contains tools with different levels of system interaction:

### Download-Only Tools

**Non App Store Apps Download** and **App Downloader** are download utilities. They download installer files to your Desktop or Downloads folder. They do **not install, open, modify, or execute** any software. What you do with the downloaded files is entirely your responsibility.

### Package Manager Tools

**Package Manager Setup** installs and configures package managers ([Homebrew](https://brew.sh/) on macOS, [Chocolatey](https://chocolatey.org/) on Windows) and uses them to install developer tools and applications. **Review the package list in each script before running.** The Windows script requires administrator privileges.

### Repo Sync Tools

**Repo Sync** clones and updates GitHub repositories into your `~/Developer` folder using standard Git operations (`git clone`, `git pull`). It reads your GitHub account's repo list via the GitHub CLI but does not modify any repository content.

## Use With Care

These tools automate common developer setup tasks. Please use them responsibly:

- **Review scripts before running.** Open each script in a text editor to understand what it will do.
- **Customize package lists.** The default package lists are starting points — edit them to match your needs.
- **Only download software you recognize and trust.** Do not add unfamiliar apps without researching them first.
- **Review downloaded files before installing.** Verify the developer and application before opening any installer.

> **Note:** These tools are shared for educational purposes — review and understand each script before running it.

## Third-Party Software

These tools are **not affiliated with, endorsed by, or sponsored by** any of the software vendors whose products they help download or install. All application names, logos, and trademarks are the property of their respective owners.

## Download Sources

Download tools resolve URLs from the following trusted sources:

- **Homebrew Cask** — A community-maintained, open-source database of official macOS application download URLs. Maintained at [github.com/Homebrew/homebrew-cask](https://github.com/Homebrew/homebrew-cask).
- **Chocolatey** — A community-maintained Windows package manager. Packages at [community.chocolatey.org](https://community.chocolatey.org/).
- **GitHub Releases** — Downloads directly from the developer's GitHub release page.
- **Vendor URLs** — Direct download links from official vendor websites.

These tools do not host, mirror, redistribute, or modify any third-party software. All downloads are fetched directly from the original publisher's servers.

## Intended Use

These tools are designed for:

- **System reloads** — Quickly setting up a fresh macOS or Windows install
- **New machine setup** — Getting a development environment running fast
- **Keeping repos in sync** — Cloning and updating all your GitHub repos at once
- **Batch downloading** — Saving time by downloading everything at once instead of visiting individual websites

## No Warranty

This software is provided "as is" without warranty of any kind. The authors are not responsible for:

- The content, safety, or functionality of any third-party software downloaded or installed using these tools
- Any changes to download URLs or packages made by third-party vendors or community maintainers
- Any damage or data loss resulting from the use of these tools
- The availability or uptime of third-party download servers or package repositories

## User Responsibility

By using these tools, you acknowledge that:

- You are responsible for reviewing the scripts and understanding what they do before running them
- You are responsible for verifying that each app or package is from a trusted source
- You are responsible for reviewing and accepting the license agreements of any software you download or install
- You assume all risk associated with downloading, installing, and running third-party software
- You will comply with all applicable laws and software license terms

## System Permissions

### macOS

- **Apple Shortcuts** require enabling "Allow Running Scripts" in Shortcuts > Settings > Advanced. Disable this after use for security.
- **Homebrew** requires admin password on first install.
- macOS Gatekeeper verifies code signatures before apps can run. Keep Gatekeeper enabled.

### Windows

- **Chocolatey** requires administrator privileges (UAC prompt).
- **Power Automate Desktop** flows run PowerShell scripts. Review `.pad` files before importing.
- PowerShell execution policy may need to be set to allow script execution.

## Contact

Questions or concerns? Open an issue on [GitHub](https://github.com/DJCastle/toolBox/issues) or visit the [CodeCraftedApps Contact page](https://codecraftedapps.com/contact.html).
