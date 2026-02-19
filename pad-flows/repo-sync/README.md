# Repo Sync — PAD Flow

Power Automate Desktop flow that clones and updates all your GitHub repos. Import and run with one click — the flow launches PowerShell and runs the script from this repo.

---

## Import

1. Open **Power Automate Desktop** > **+ New flow**
2. Name it "Dev Clone Repos"
3. Open `Dev-Clone-Repos.pad` in a text editor, select all, copy
4. Paste into the PAD flow editor and save

---

## What It Does

1. Checks if `~\Developer\toolBox` exists — clones the repo if not
2. Opens a **PowerShell window**
3. Runs [`clone-repos.ps1`](../../scripts/repo-sync/clone-repos.ps1) which:
   - Authenticates with GitHub (prompts to log in if needed)
   - Fetches your full repo list via the GitHub API
   - Shows an interactive menu to choose what to sync:
     - **Option 1)** Sync repos tagged for Windows only
     - **Option 2)** Sync ALL repos regardless of platform
     - **Option 3)** Pick specific repos from a numbered list
   - Clones missing repos, pulls updates for existing ones

---

## Platform Filtering

Repos are filtered by [GitHub repository topics](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics):

| Topic | Behavior |
| ----- | -------- |
| `windows` | Cloned on Windows |
| `cross-platform` | Cloned on both macOS and Windows |
| `macos` | Skipped on Windows |
| _(no topic)_ | Skipped with warning |

Tag your repos: `gh repo edit YOUR_USERNAME/<repo> --add-topic windows`

---

## Configuration

To change the defaults, edit `scripts\repo-sync\clone-repos.ps1`:

- **`$GitHubUser`** (~line 55) — leave empty to auto-detect from `gh auth`, or set explicitly
- **`$DevDir`** (~line 56) — where repos are cloned (default: `~\Developer`)
- **`$SkipRepos`** (~line 61) — repos to skip (managed separately)

---

## Requirements

- Windows 10/11
- Power Automate Desktop (pre-installed on Windows 11, [free download](https://learn.microsoft.com/en-us/power-automate/desktop-flows/install) for Windows 10)
- [gh](https://cli.github.com/) (GitHub CLI) — installed by [choco-setup.ps1](../../scripts/package-manager-setup/)
- Git (for initial repo clone)
- Internet connection

---

## See Also

- [PowerShell Script](../../scripts/repo-sync/) — run directly from PowerShell (also has `-Check` mode)
- [Apple Shortcut](../../shortcuts/repo-sync/) — macOS equivalent via Shortcuts.app
