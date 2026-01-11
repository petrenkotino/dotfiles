#!/bin/sh

set -e

echo "Setting up your Mac ❤️..."

DOTFILES_DIR="${HOME}/.dotfiles"
ZSH_CUSTOM_DIR="${HOME}/.zsh/custom"
OMZ_CUSTOM_DIR="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
BREWFILE="${DOTFILES_DIR}/Brewfile"

log_step() {
  printf '\n==> %s\n' "$1"
}

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

# Symlink the main zsh config
log_step "Linking shell configuration"
ln -sf "${DOTFILES_DIR}/.zshrc" "${HOME}/.zshrc"

# Ensure custom zsh folder exists and link aliases
log_step "Ensuring custom zsh directory and aliases"
mkdir -p "${ZSH_CUSTOM_DIR}"
ln -sf "${DOTFILES_DIR}/aliases.zsh" "${ZSH_CUSTOM_DIR}/aliases.zsh"

log_step "Ensuring custom paths"
ln -sf "${DOTFILES_DIR}/path.zsh" "${ZSH_CUSTOM_DIR}/path.zsh"

echo "→ Linking ~/bin to ~/.dotfiles/bin scripts..."
mkdir -p ~/bin
for script in ~/.dotfiles/bin/*; do
  ln -sf "$script" ~/bin/
done

chmod +x ~/.dotfiles/bin/*
echo "✅ Bin scripts linked and executable."

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

log_step "Installing Homebrew bundle packages"
brew bundle --file "${BREWFILE}"

# Install tmux plugin manager if missing
if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
  log_step "Installing tmux plugin manager (TPM)"
  git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
else
  log_step "TPM already installed"
fi

# Install Pure prompt locally if missing
if [ ! -d "${HOME}/.zsh/pure" ]; then
  log_step "Installing Pure prompt"
  git clone https://github.com/sindresorhus/pure.git "${HOME}/.zsh/pure"
else
  log_step "Pure prompt already installed"
fi

# Ensure oh-my-zsh custom plugins exist before cloning
log_step "Ensuring Oh My Zsh custom plugins directory"
mkdir -p "${OMZ_CUSTOM_DIR}/plugins"

if [ ! -d "${OMZ_CUSTOM_DIR}/plugins/zsh-autosuggestions" ]; then
  log_step "Installing zsh-autosuggestions plugin"
  git clone https://github.com/zsh-users/zsh-autosuggestions "${OMZ_CUSTOM_DIR}/plugins/zsh-autosuggestions"
else
  log_step "zsh-autosuggestions already installed"
fi

if [ ! -d "${OMZ_CUSTOM_DIR}/plugins/zsh-nvm" ]; then
  log_step "Installing zsh-nvm plugin"
  git clone https://github.com/lukechilds/zsh-nvm.git "${OMZ_CUSTOM_DIR}/plugins/zsh-nvm"
else
  log_step "zsh-nvm already installed"
fi

if [ ! -d "${OMZ_CUSTOM_DIR}/plugins/aws-mfa" ]; then
  log_step "Installing aws-mfa plugin"
  git clone --depth=1 https://github.com/joepjoosten/aws-cli-mfa-oh-my-zsh.git "${OMZ_CUSTOM_DIR}/plugins/aws-mfa"
else
  log_step "aws-mfa already installed"
fi

# Symlink the Mackup config file to the home directory
log_step "Linking Mackup configuration"
ln -sf "${DOTFILES_DIR}/.mackup.cfg" "${HOME}/.mackup.cfg"

# Apply macOS preferences only on explicit request
if [ "${RUN_DOTFILES_MACOS:-0}" = "1" ]; then
  log_step "Applying macOS defaults"
  # shellcheck disable=SC1090
  . "${DOTFILES_DIR}/.macos"
else
  echo "Skipping macOS defaults (set RUN_DOTFILES_MACOS=1 to apply)."
fi
