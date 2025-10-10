# Konstantin's Dotfiles

This is a fork from [Dries Vints](https://github.com/driesvints/dotfiles)'s dotfiles. Check out his detailed documentation about all the files. I just changed a few things to better fit my needs.

Be careful when using these dotfiles because they change a lot of MacOS settings and install all the apps I need.

## Backup Checklist

- Did you commit and push any changes/branches to your git repositories?
- Did you copy your .env files to a safe place if they are not casual?
- Did you copy your IDE settings? (e.g. PhpStorm)
- Did you backup local databases you need?
- Did you remember to save all important documents from non-cloud directories?
- Did you save all of your work from apps which aren't synced through cloud?
    + Insomnia (Export to Dropbox)
- Did you update [mackup](https://github.com/lra/mackup) to the latest version and ran `mackup backup`?
- Create "Brave Sync" QR Code (Settings / Sync)

## Installation

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
   - This will install Oh My Zsh, Homebrew, brew bundle formulas/casks (Terraform, AWS, Kubernetes, linting tools, etc.), and link shell config files.
   - macOS defaults are **not** applied automatically anymore. Set `RUN_DOTFILES_MACOS=1 ~/.dotfiles/install.sh` when you explicitly want `.macos` to run.
6. Optionally `Apply macOS defaults`
    ```zsh
    RUN_DOTFILES_MACOS=1 ~/.dotfiles/install.sh
    ```
7. `Log in to Dropbox` and sync folders
8. `Sync Mackup` Folder (from Dropbox)
9. `Restore Mac settings` after Mackup is synced with your cloud storage, by running `mackup restore`
10. `Restart your computer` to finalize the process

### SSH keys helper

Generate a GitHub key safely:

```zsh
~/.dotfiles/ssh.sh "your-email@example.com"
```

The script preserves existing keys, sets the required permissions, appends to `~/.ssh/config`, and adds the key to the Apple keychain.


## Additional Steps

- Install apps manually
    [NA]
- Custom Settings
    - Copy ssh config from 1Password to `~/.ssh/config`
- Set Permissions
    - Bartender
    - Alfred

## Still Missing
- Rectangle settings?
- Disable Mac sounds
