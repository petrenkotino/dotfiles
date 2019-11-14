# Christoph Rumpel's Dotfiles

This is a fork from [Dries Vints](https://github.com/driesvints/dotfiles)'s dotfiles. Check out his detailed documentation about all the files. I just changed a few things to better fit my needs.

Be careful when using these dotfiles because they change a lot of MacOS settings and download all the apps I need.

## Backup Checklist

- Did you commit and push any changes/branches to your git repositories?
- Did you remember to save all important documents from non-iCloud directories?
- Did you save all of your work from apps which aren't synced through iCloud?
    + Insomnia (Export to Dropbox)
- Did you remember to export important data from your local database?
- Did you update [mackup](https://github.com/lra/mackup) to the latest version and ran `mackup backup`?

## Installation

- More Details here [here](https://github.com/driesvints/dotfiles)
- Update macOS to the latest version with the App Store
- Install Xcode from the App Store, open it and accept the license agreement
- Install macOS Command Line Tools by running xcode-select --install
- Copy your public and private SSH keys to ~/.ssh and make sure they're set to 600 (Or Create new ones)
- Clone this repo to ~/.dotfiles
- Install Oh My Zsh
- Run install.sh to start the installation
- SignIn to 1Password for Dropbox credentials
- Open Dropbox and sync Mackup (in my case I use Dropbox)
- After mackup is synced with your cloud storage, restore preferences by running `mackup restore`
- Restart your computer to finalize the process

## Still Missing

- Backup Spark Mail Accounts
- Activate right mouse click
- Sleep time missmatch/error
- Install Virtualbox Error (Needs to be allowed in preferences)
- Brave extensions are not synced
