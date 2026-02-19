# Repo Sync — Shell Scripts

Cross-platform scripts that clone all your GitHub repos into `~/Developer` and keep them updated. Interactive menu lets you choose what to sync. Idempotent — safe to run anytime.

---

## macOS — `clone-repos.sh`

```bash
bash clone-repos.sh              # Interactive clone/update
bash clone-repos.sh --check      # Report only — no changes made
```

## Windows — `clone-repos.ps1`

```powershell
.\clone-repos.ps1                # Interactive clone/update
.\clone-repos.ps1 -Check         # Report only — no changes made
```

---

## How It Works

1. Authenticates with GitHub (prompts to log in if needed)
2. Fetches your full repo list via the GitHub API
3. Shows an interactive menu:
   - **Option 1)** Sync repos tagged for this OS only
   - **Option 2)** Sync ALL repos regardless of platform
   - **Option 3)** Pick specific repos from a numbered list
4. Clones missing repos, pulls updates for existing ones
5. Prints a summary of what was synced

---

## Platform Filtering

Repos are filtered by [GitHub repository topics](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics):

| Topic | macOS | Windows |
| ----- | :---: | :-----: |
| `macos` | Cloned | Skipped |
| `windows` | Skipped | Cloned |
| `cross-platform` | Cloned | Cloned |
| _(no topic)_ | Skipped with warning | Skipped with warning |

Tag a repo:

```bash
gh repo edit YOUR_USERNAME/<repo> --add-topic macos
gh repo edit YOUR_USERNAME/<repo> --add-topic cross-platform
```

---

## Configuration

| Setting | Default | Description |
| ------- | ------- | ----------- |
| `GITHUB_USER` / `$GitHubUser` | _(auto-detect)_ | Leave empty to detect from `gh auth`. Or set explicitly. |
| `DEV_DIR` / `$DevDir` | `~/Developer` | Where repos are cloned |
| `SKIP_REPOS` / `$SkipRepos` | _(empty)_ | Repos to skip (managed separately) |

---

## Requirements

- [gh](https://cli.github.com/) (GitHub CLI) — installed by brew-setup.sh / choco-setup.ps1
- [jq](https://jqlang.github.io/jq/) (macOS only) — installed by brew-setup.sh
- Internet connection

---

## See Also

- [Apple Shortcut](../../shortcuts/repo-sync/) — run the macOS script from Shortcuts.app
- [PAD Flow](../../pad-flows/repo-sync/) — run the Windows script from Power Automate Desktop
