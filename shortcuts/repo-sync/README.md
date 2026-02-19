# Repo Sync — Apple Shortcut

Apple Shortcuts version that clones and updates all your GitHub repos. Import and run with one click — the shortcut launches Terminal and runs the shell script from this repo.

---

## Security

This shortcut runs a shell script. Before using it:

1. Open **Shortcuts.app** > **Settings** > **Advanced**
2. Enable **Allow Running Scripts**
3. Run the shortcut
4. **Disable "Allow Running Scripts" when done** — best practice to keep this off when not in use

---

## Import

Double-click **Dev-Clone-Repos.shortcut** to import into Shortcuts.app, or:

1. Open **Shortcuts.app**
2. File > Import...
3. Select `Dev-Clone-Repos.shortcut`

---

## What It Does

1. Checks if `~/Developer/toolBox` exists — clones the repo if not
2. Opens **Terminal.app**
3. Runs [`clone-repos.sh`](../../scripts/repo-sync/clone-repos.sh) which:
   - Authenticates with GitHub (prompts to log in if needed)
   - Fetches your full repo list via the GitHub API
   - Shows an interactive menu to choose what to sync:
     - **Option 1)** Sync repos tagged for macOS only
     - **Option 2)** Sync ALL repos regardless of platform
     - **Option 3)** Pick specific repos from a numbered list
   - Clones missing repos, pulls updates for existing ones

---

## Platform Filtering

Repos are filtered by [GitHub repository topics](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics):

| Topic | Behavior |
| ----- | -------- |
| `macos` | Cloned on macOS |
| `cross-platform` | Cloned on both macOS and Windows |
| `windows` | Skipped on macOS |
| _(no topic)_ | Skipped with warning |

Tag your repos: `gh repo edit YOUR_USERNAME/<repo> --add-topic macos`

---

## Configuration

To change the defaults, edit `scripts/repo-sync/clone-repos.sh`:

- **`GITHUB_USER`** (~line 57) — leave empty to auto-detect from `gh auth`, or set explicitly
- **`DEV_DIR`** (~line 58) — where repos are cloned (default: `~/Developer`)
- **`SKIP_REPOS`** (~line 63) — repos to skip (managed separately)

---

## Requirements

- macOS 12.0+ (Monterey) — Shortcuts.app required
- [gh](https://cli.github.com/) (GitHub CLI) — installed by [brew-setup.sh](../../scripts/package-manager-setup/)
- Internet connection

---

## See Also

- [Shell Script](../../scripts/repo-sync/) — run directly from Terminal (also has `--check` mode)
- [PAD Flow](../../pad-flows/repo-sync/) — Windows equivalent via Power Automate Desktop
