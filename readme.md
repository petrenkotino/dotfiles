# Konstantin's Dotfiles

This is a fork from [Dries Vints](https://github.com/driesvints/dotfiles)'s dotfiles. Check out his detailed documentation about all the files. I just changed a few things to better fit my needs.

## Supported systems

| OS | Status | Installer |
|---|---|---|
| macOS (Apple Silicon / Intel) | Primary workstation | `macos/install.sh` (Homebrew + `macos/Brewfile`) |
| Ubuntu 26.04 LTS Desktop, amd64 | Home workstation / homelab host | `linux/install.sh` (apt + vendor apt repos) |

`./install.sh` detects the OS and dispatches to the right installer. Both are idempotent and safe to re-run.

## Layout

```text
install.sh            # OS detection → macos/ or linux/
common/               # shared by both platforms
  lib.sh              #   installer helpers: log, run (dry-run), link (with backup), clone_once
  zsh/.zshrc          #   → ~/.zshrc (tools are initialised only if installed)
  zsh/path.zsh        #   → ~/.zsh/custom/path.zsh
  zsh/aliases.zsh     #   → ~/.zsh/custom/aliases.zsh
  .tmux.conf          #   → ~/.tmux.conf
  nvim/               #   → ~/.config/nvim (NvChad)
  vim/vimrc           #   → ~/.vimrc
macos/                # install.sh, Brewfile, aliases.zsh (→ aliases-os.zsh), .macos, .mackup.cfg
linux/                # install.sh, packages.sh, versions.sh, aliases.zsh (→ aliases-os.zsh)
bin/                  # personal scripts → ~/bin
.zsh.froda, aliases-froda.zsh   # work config, linked on macOS only
```

---

## Ubuntu (fresh machine)

### Prerequisites

- Ubuntu 26.04 LTS Desktop, amd64, a normal user with `sudo` rights (don't run the installer as root).
- `git` and `curl` (preinstalled on Desktop; otherwise `sudo apt install git curl`).

### Install

```bash
git clone https://github.com/petrenkotino/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh --dry-run --profile dev   # optional: see what would change
./install.sh --profile dev             # or omit --profile for base
```

Then log out and back in (the login shell is changed to zsh). On the first zsh start, `zsh-nvm` installs nvm. In tmux, press `prefix + I` to install the tmux plugins. Opening `nvim` the first time bootstraps NvChad's plugins.

### Profiles

| Profile | Installs |
|---|---|
| `base` (default) | apt: zsh, git, curl, wget, make, build-essential, tmux, neovim, fzf, ripgrep, bat, fd-find, jq, unzip, gnupg. Oh My Zsh, Pure prompt, zsh-autosuggestions, zsh-nvm, TPM. All symlinks, login shell → zsh |
| `dev` | base + direnv, Go (`golang-go`). From vendor apt repos: GitHub CLI, kubectl, Helm, OpenTofu. Pinned, sha256-verified release binaries in `~/.local/bin`: uv, k9s |

Options: `--profile base|dev` (or `PROFILE=dev`), `--dry-run` (or `DRY_RUN=1`), `--help`.

### What the installer touches

- **sudo** is used only for `apt-get`, `/etc/apt/keyrings/*.gpg`, `/etc/apt/sources.list.d/{github-cli,kubernetes,helm,opentofu}.list` and `chsh`.
- Everything else lives in `$HOME`: `~/.oh-my-zsh`, `~/.zsh/`, `~/.tmux/plugins`, `~/.local/bin`, `~/bin` and the symlinks listed above.
- Nothing is appended to shell rc files. No services, Docker daemon, firewall, network or storage changes.

---

## macOS

### Backup checklist (before wiping a Mac)

- Did you commit and push any changes/branches to your git repositories?
- Did you copy your .env files to a safe place if they are not casual?
- Did you copy your IDE settings? (e.g. PhpStorm)
- Did you backup local databases you need?
- Did you remember to save all important documents from non-cloud directories?
- Did you save all of your work from apps which aren't synced through cloud?
    + Insomnia (Export to Dropbox)
- Did you update [mackup](https://github.com/lra/mackup) to the latest version and ran `mackup backup`?
- Create "Brave Sync" QR Code (Settings / Sync)

### Installation

Be careful: the macOS installer installs all the apps I need, and can optionally change a lot of macOS settings.

1. `Update macOS` to the latest version with the App Store
2. `Create new SSH keys` or copy given ones to `SSH keys to ~/.ssh` and make sure they're set to 600
   ```zsh
   curl https://raw.githubusercontent.com/petrenkotino/dotfiles/master/ssh.sh | sh -s "petrenkotino@gmail.com"
   ```
3. `Sign to 1Password` and add new SSH keys to GitHub (for loading private repos)
4. `Clone dotfiles` to ~/.dotfiles (you will be asked to download command line tools)
    ```zsh
    git clone https://github.com/petrenkotino/dotfiles.git ~/.dotfiles
    ```
5. `Run Installation` script (idempotent, safe to re-run)
    ```zsh
    ~/.dotfiles/install.sh
    ```
   - This installs Oh My Zsh, Homebrew and the `macos/Brewfile` formulas/casks, and links the shell config files.
   - macOS defaults are **not** applied automatically. Use `RUN_DOTFILES_MACOS=1 ~/.dotfiles/install.sh` when you explicitly want `macos/.macos` to run.
   - `--profile` / `--dry-run` are Linux-only; the macOS installer refuses arguments.
6. `Log in to Dropbox` and sync folders
7. `Sync Mackup` Folder (from Dropbox)
8. `Restore Mac settings` after Mackup is synced with your cloud storage, by running `mackup restore`
9. `Restart your computer` to finalize the process

> **Upgrading an existing Mac to this layout:** the config files moved into `common/` and `macos/`, so after `git pull` the old `~/.zshrc` and `~/.tmux.conf` symlinks are dangling until you rerun `~/.dotfiles/install.sh`. Do that from a shell that is already open, or run `zsh -f` first. The installer now also links `~/.config/nvim` and `~/.vimrc`; an existing real directory/file there is moved to `*.bak.<timestamp>`.

### SSH keys helper (macOS)

```zsh
~/.dotfiles/ssh.sh "your-email@example.com"
```

The script preserves existing keys, sets the required permissions, appends to `~/.ssh/config`, and adds the key to the Apple keychain. It uses the macOS keychain and `pbcopy`, so on Ubuntu generate keys with `ssh-keygen -t ed25519` and use `ssh-agent` / the GNOME keyring instead. Keys and credentials never go into this repository.

---

## Python: uv on both platforms

[uv](https://docs.astral.sh/uv/) manages Python versions, virtualenvs, dependencies, lockfiles and Python CLI tools. pyenv, Poetry, pipx and pip-tools are not installed by default. The OS Python (`/usr/bin/python3`) is never modified or shadowed. uv-managed interpreters live in `~/.local/share/uv/python` and are used through uv.

- Install: `brew 'uv'` on macOS, a pinned release tarball on Ubuntu (`linux/versions.sh`).
- PATH: `~/.local/bin` (uv itself on Linux, plus `uv tool install` shims) is added by `common/zsh/path.zsh`.

Common workflows:

```bash
uv init myproj && cd myproj        # new project (pyproject.toml)
uv python pin 3.13                 # writes .python-version (uv also reads existing pyenv ones)
uv add requests                    # add dependency, updates uv.lock
uv sync                            # create/refresh .venv from the lockfile
uv run pytest                      # run inside the project env
uvx ruff check .                   # run a tool once, without installing it
uv tool install pre-commit         # install a CLI tool onto PATH
uv python install 3.12 3.13        # install interpreters explicitly
```

Migrating from pyenv (macOS): `.zshrc` still runs `pyenv init` **only if pyenv is installed**, so existing projects keep working. Install the versions you use with `uv python install <versions>`, switch projects over to `uv venv` / `uv sync`, then `brew uninstall pyenv` and remove `~/.pyenv` when nothing needs it.

---

## macOS vs Linux

| | macOS | Ubuntu |
|---|---|---|
| Packages | Homebrew, `macos/Brewfile` | apt + vendor repos, `linux/packages.sh` |
| Pinned binaries | — | `linux/versions.sh` (uv, k9s, plugin tags) |
| OS aliases | Finder/`defaults`, `ipconfig`, `stat -f` | `batcat`→`bat`, `xdg-open`→`open`, `hostname -I`, `stat -c` |
| `bat` / `fd` | `bat` / `fd` | `batcat` (aliased to `bat`) / `fdfind`. `fd` is a dir-picker function in `.zshrc` on both |
| GNU coreutils/sed | Homebrew, gnu-sed first on PATH | native |
| Work (Froda) config, aws-mfa, kubesess, gcloud, Rancher | yes | no |
| `.macos` defaults, Mackup, Rosetta, casks, App Store apps | yes | no |

## Dependency classification

| Class | Items |
|---|---|
| **Essential** (`base`) | zsh, Oh My Zsh, Pure, zsh-autosuggestions, zsh-nvm, tmux + TPM, neovim, fzf, ripgrep, bat, fd, jq, git, curl, wget, make, build-essential |
| **Optional** (`dev`) | uv, Node via nvm, Go, direnv, gh, kubectl, Helm, k9s, OpenTofu |
| **macOS-only** | casks, mas apps, coreutils/gnu-sed/grep/bash from brew, Rosetta, `.macos`, Mackup, Rancher Desktop |
| **Deferred / work-specific** | awscli, aws-vault, aws-mfa, eksctl, eks-node-viewer, e1s, kubelogin, az, session-manager-plugin, sops, yq, stern, kustomize, kubectx, kubesess, krew, helmfile, argocd, terraform, terragrunt, terraform-docs, tflint, tfsec, checkov, hadolint, pre-commit (`uv tool install`), lazygit, gcloud, docker tooling |

## Adding packages

- **Ubuntu, from the Ubuntu archive:** add the name to `BASE_PACKAGES` or `DEV_PACKAGES` in `linux/packages.sh`.
- **Ubuntu, from a vendor apt repo:** add an `add_apt_key` + `add_apt_source` pair to `add_dev_repos` in `linux/packages.sh` (keys go to `/etc/apt/keyrings`, always `signed-by=`). Then add the package to `DEV_PACKAGES`.
- **Ubuntu, release binary:** add version + sha256 to `linux/versions.sh` and an `install_tarball` call in `install_dev_binaries`. Take the checksum from the project's published checksum file.
- **Python CLI tools:** `uv tool install <tool>` rather than apt/pip.
- **macOS:** add a line to `macos/Brewfile`.
- **Shell init for a new tool:** guard it in `.zshrc` with `(( $+commands[tool] ))` so a missing tool never breaks startup.
- **Aliases:** portable ones go in `common/zsh/aliases.zsh`, OS-specific ones in `macos/aliases.zsh` / `linux/aliases.zsh`.

Upgrading pinned versions: edit `linux/versions.sh` and rerun `./install.sh --profile dev`. The binaries are replaced when the reported version differs. For a new kubectl minor, bump `KUBERNETES_MINOR`; the repo key is replaced too. Packages from apt repos update with the normal `sudo apt upgrade`.

## Re-running safely

- Already-installed packages, keys, repos, clones and correct symlinks are detected and reported as `ok`.
- A real file or directory where a symlink should go is moved to `<path>.bak.<timestamp>`, never deleted.
- Use `--dry-run` to preview any run.

## Desktop apps on Ubuntu (not installed; install manually)

| App | Recommended method |
|---|---|
| VS Code | Microsoft apt repo (`packages.microsoft.com/repos/code`), settings in `vscode/` |
| Terminal | Ghostty (official .deb / Ubuntu package) or kitty (`apt install kitty`) |
| Browser | Firefox (preinstalled snap), Chrome/Brave via their apt repos |
| 1Password + `op` CLI | 1Password apt repo (`downloads.1password.com/linux/debian`). The OMZ `1password` plugin loads automatically once `op` exists |
| Obsidian, Spotify, Slack, Zoom | Flatpak (Flathub) or the vendor .deb |

## Known limitations

- The Ubuntu installer is tested on 26.04 amd64 only. The pinned release binaries are amd64-only, so `dev` fails on arm64 (`base` works).
- Oh My Zsh and zsh-nvm track their default branch (OMZ updates itself), and nvm is installed by zsh-nvm on first shell start. The other plugins are pinned to tags.
- The `fd()` function in `.zshrc` shadows the `fd` binary on macOS. On Ubuntu use `fdfind`.
- The macOS installer was refactored (paths and the link helper) but can only be verified on a Mac.
- Homelab (KVM/libvirt, Docker, Kubernetes, networking) is intentionally out of scope and will live in a separate infrastructure repository.

## Troubleshooting

- **`apt-get update` fails on a vendor repo:** check `/etc/apt/sources.list.d/<name>.list` and the matching key in `/etc/apt/keyrings/`. Delete both and rerun to re-fetch.
- **Still in bash after installing:** `chsh` takes effect at the next login. Log out and back in, or run `zsh` in the meantime.
- **`bat` / `fd` not found on Ubuntu:** they're `batcat` / `fdfind`. `bat` is aliased in `linux/aliases.zsh`.
- **Shell startup errors:** run `zsh -x -i -c exit 2>&1 | less` to find the failing line. Every tool init in `.zshrc` should be guarded.
- **`checksum mismatch`:** the download changed, or the pin in `linux/versions.sh` is wrong. Re-check it against the release's checksum file.
- **tmux plugins missing:** `prefix + I` inside tmux (TPM must exist at `~/.tmux/plugins/tpm`).
- **macOS: shell broken after pulling:** see "Upgrading an existing Mac" above.
