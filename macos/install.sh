#!/bin/sh

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OMZ_CUSTOM_DIR="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
BREWFILE="${DOTFILES_DIR}/macos/Brewfile"

# shellcheck source=SCRIPTDIR/../common/lib.sh
. "${DOTFILES_DIR}/common/lib.sh"

if [ $# -gt 0 ]; then
  die "options ($*) are only supported on Linux; run without arguments"
fi

echo "Setting up your Mac ❤️..."

if command -v sudo >/dev/null 2>&1; then
  log_step "Refreshing sudo credentials (you may be prompted once)"
  sudo -v
  (
    while true; do
      sudo -n true 2>/dev/null || exit
      sleep 60
    done
  ) &
  SUDO_LOOP_PID=$!
  trap 'if [ -n "${SUDO_LOOP_PID:-}" ]; then kill "${SUDO_LOOP_PID}" 2>/dev/null || true; fi' EXIT
fi

# Install Oh My Zsh if it is missing
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  log_step "Installing Oh My Zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
else
  log_step "Oh My Zsh already installed"
fi

# Install Homebrew if it is missing
if ! command -v brew >/dev/null 2>&1; then
  log_step "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  log_step "Homebrew already installed"
fi

# Symlink shell, tmux, vim/nvim config, aliases, paths and ~/bin scripts
# (existing real files are backed up to *.bak.<timestamp>)
log_step "Linking shell configuration"
link_common "${DOTFILES_DIR}" macos

# Shell plugins and prompt. Done before Homebrew so a failing brew step
# never leaves the shell half set up.
log_step "Installing shell plugins"
mkdir -p "${OMZ_CUSTOM_DIR}/plugins"
clone_once https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
clone_once https://github.com/sindresorhus/pure.git "${HOME}/.zsh/pure"
clone_once https://github.com/zsh-users/zsh-autosuggestions "${OMZ_CUSTOM_DIR}/plugins/zsh-autosuggestions"
clone_once https://github.com/joepjoosten/aws-cli-mfa-oh-my-zsh.git "${OMZ_CUSTOM_DIR}/plugins/aws-mfa"

# Symlink the Mackup config file to the home directory
log_step "Linking Mackup configuration"
link "${DOTFILES_DIR}/macos/.mackup.cfg" "${HOME}/.mackup.cfg"

# Update Homebrew recipes
log_step "Updating Homebrew formulae"
brew update

# Install Rosetta only on Apple Silicon and only once
if [ "$(uname -m)" = "arm64" ]; then
  if ! /usr/bin/pgrep -q oahd; then
    log_step "Installing Rosetta (Apple Silicon)"
    sudo softwareupdate --install-rosetta --agree-to-license
  else
    log_step "Rosetta already installed"
  fi
else
  log_step "Rosetta not required on Intel"
fi

# Install brew bundle dependencies
log_step "Preparing Homebrew taps"
if ! brew tap | grep -q "^aws/tap$"; then
  brew tap aws/tap
fi

if ! brew tap | grep -q "^keidarcy/tap$"; then
  brew tap keidarcy/tap
fi

if ! brew tap | grep -q "^hashicorp/tap$"; then
  brew tap hashicorp/tap
fi

# A single failing entry (an app already installed outside Homebrew, a
# Mac App Store app while signed out) must not abort the rest of the setup.
log_step "Installing Homebrew bundle packages"
BUNDLE_FAILED=0
brew bundle --file "${BREWFILE}" || BUNDLE_FAILED=1

# Apply macOS preferences only on explicit request
if [ "${RUN_DOTFILES_MACOS:-0}" = "1" ]; then
  log_step "Applying macOS defaults"
  # shellcheck disable=SC1090
  . "${DOTFILES_DIR}/macos/.macos"
else
  echo "Skipping macOS defaults (set RUN_DOTFILES_MACOS=1 to apply)."
fi

if [ "${BUNDLE_FAILED}" = "1" ]; then
  echo "Warning: some Brewfile entries failed; run 'brew bundle check --verbose --file ${BREWFILE}' to see which."
fi
