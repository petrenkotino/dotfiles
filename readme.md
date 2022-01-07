# Christoph Rumpel's Dotfiles

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
   curl https://raw.githubusercontent.com/christophrumpel/dotfiles/master/ssh.sh | sh -s "christoph@christoph-rumpel.com"
   ```
3. `Clone dotfiles` to ~/.dotfiles (you will be asked to download command line tools)
    ```zsh
    git clone https://github.com/christophrumpel/dotfiles.git ~/.dotfiles
    ```
4. `Run Installation` script
    ```zsh
    ~/.dotfiles/install.sh
    ```
5. `SignIn to 1Password` for Dropbox credentials
6. `Sync Mackup` Folder (from Dropbox)
7. `Restore Mac settings" After mackup is synced with your cloud storage, by running `mackup restore`
8. `Restart your computer` to finalize the process


## Additional Steps

- Install apps manually
    - Davinci Resolve
    - Ecamm Live
    - Descript
    - Pixelmator Pro Demo (Dropbox/Backups)
- Custom Settings
    - Spark: Log in with your main email account to load the others
    - Brave: Using created Sync QR code to sync extensions
    - Copy ssh config from 1Password to `~/.ssh/config`
    - PhpStorm: enable repository sync `https://github.com/christophrumpel/phpstorm-settings`
- Set Permissions
    - Bartender
    - Alfred

## Still Missing

- Activate right mouse click
- Sleep time missmatch/error
- Rectangle settings?
- Operator Mono font
- Disable Mac sounds
- Modifier keys: Switch caps lock to Esc, possible through commandline?
