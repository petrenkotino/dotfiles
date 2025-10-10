#!/bin/sh

set -e

echo "Setting up your Mac ❤️..."

DOTFILES_DIR="${HOME}/.dotfiles"
ZSH_CUSTOM_DIR="${HOME}/.zsh/custom"
OMZ_CUSTOM_DIR="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
BREWFILE="${DOTFILES_DIR}/Brewfile"

# Install Oh My Zsh if it is missing
if ! command -v omz >/dev/null 2>&1; then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Install Homebrew if it is missing
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Symlink the main zsh config
ln -sf "${DOTFILES_DIR}/.zshrc" "${HOME}/.zshrc"

# Ensure custom zsh folder exists and link aliases
mkdir -p "${ZSH_CUSTOM_DIR}"
ln -sf "${DOTFILES_DIR}/aliases.zsh" "${ZSH_CUSTOM_DIR}/aliases.zsh"

# Update Homebrew recipes
brew update

# Install Rosetta only on Apple Silicon and only once
if [ "$(uname -m)" = "arm64" ]; then
  if ! /usr/bin/pgrep -q oahd; then
    sudo softwareupdate --install-rosetta --agree-to-license
  fi
fi

# Install brew bundle dependencies
brew tap homebrew/bundle
brew tap homebrew/cask-drivers
brew bundle --file "${BREWFILE}"

# Install tmux plugin manager if missing
if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
fi

# Install Pure prompt locally if missing
if [ ! -d "${HOME}/.zsh/pure" ]; then
  git clone https://github.com/sindresorhus/pure.git "${HOME}/.zsh/pure"
fi

# Ensure oh-my-zsh custom plugins exist before cloning
mkdir -p "${OMZ_CUSTOM_DIR}/plugins"

if [ ! -d "${OMZ_CUSTOM_DIR}/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "${OMZ_CUSTOM_DIR}/plugins/zsh-autosuggestions"
fi

if [ ! -d "${OMZ_CUSTOM_DIR}/plugins/zsh-nvm" ]; then
  git clone https://github.com/lukechilds/zsh-nvm.git "${OMZ_CUSTOM_DIR}/plugins/zsh-nvm"
fi

if [ ! -d "${OMZ_CUSTOM_DIR}/plugins/aws-mfa" ]; then
  git clone --depth=1 https://github.com/joepjoosten/aws-cli-mfa-oh-my-zsh.git "${OMZ_CUSTOM_DIR}/plugins/aws-mfa"
fi

# Symlink the Mackup config file to the home directory
ln -sf "${DOTFILES_DIR}/.mackup.cfg" "${HOME}/.mackup.cfg"

# Apply macOS preferences only on explicit request
if [ "${RUN_DOTFILES_MACOS:-0}" = "1" ]; then
  # shellcheck disable=SC1090
  . "${DOTFILES_DIR}/.macos"
else
  echo "Skipping macOS defaults (set RUN_DOTFILES_MACOS=1 to apply)."
fi
