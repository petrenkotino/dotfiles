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
5. `Run Installation` script
    ```zsh
    ~/.dotfiles/install.sh
    ```
6. `Log in to Dropbox` and sync folders
7. `Sync Mackup` Folder (from Dropbox)
8. `Restore Mac settings" After mackup is synced with your cloud storage, by running `mackup restore`
9. `Restart your computer` to finalize the process


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
