#!/usr/bin/env bash
# Ubuntu bootstrap. Usually run via ../install.sh; safe to re-run.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OMZ_CUSTOM_DIR="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
PROFILE="${PROFILE:-base}"

# shellcheck source=SCRIPTDIR/../common/lib.sh
. "${DOTFILES_DIR}/common/lib.sh"
# shellcheck source=SCRIPTDIR/versions.sh
. "${DOTFILES_DIR}/linux/versions.sh"
# shellcheck source=SCRIPTDIR/packages.sh
. "${DOTFILES_DIR}/linux/packages.sh"

usage() {
  cat <<EOF
Usage: install.sh [--profile base|dev] [--dry-run]

  --profile base   shell, tmux, neovim, core CLI tools (default)
  --profile dev    base + direnv, Go, uv, gh, kubectl, helm, k9s, OpenTofu
  --dry-run        print what would change without changing anything
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --profile) PROFILE="${2:-}"; shift 2 ;;
    --profile=*) PROFILE="${1#*=}"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; die "unknown argument: $1" ;;
  esac
done

case "${PROFILE}" in
  base|dev) ;;
  *) die "unknown profile: ${PROFILE} (expected base or dev)" ;;
esac

[ "$(id -u)" -ne 0 ] || die "run as your normal user; sudo is used only where needed"

# shellcheck source=/dev/null
. /etc/os-release
if [ "${ID:-}" != "ubuntu" ]; then
  log_info "warning: tested on Ubuntu 26.04, found ${PRETTY_NAME:-unknown}; continuing"
fi

echo "Setting up ${PRETTY_NAME:-Linux} (profile: ${PROFILE}$([ "${DRY_RUN}" = "1" ] && echo ', dry run'))"

if [ "${DRY_RUN}" != "1" ]; then
  log_step "Checking sudo (you may be prompted once)"
  sudo -v
fi

log_step "Installing base packages"
apt_install "${BASE_PACKAGES[@]}"

if [ "${PROFILE}" = "dev" ]; then
  log_step "Adding vendor apt repositories"
  add_dev_repos

  log_step "Installing dev packages"
  apt_install "${DEV_PACKAGES[@]}"

  log_step "Installing pinned release binaries"
  install_dev_binaries
fi

# Oh My Zsh tracks master and updates itself, so it is cloned rather than pinned
log_step "Installing Oh My Zsh, Pure and plugins"
clone_once https://github.com/ohmyzsh/ohmyzsh.git "${HOME}/.oh-my-zsh"
clone_once https://github.com/sindresorhus/pure.git "${HOME}/.zsh/pure" "${PURE_TAG}"
clone_once https://github.com/zsh-users/zsh-autosuggestions "${OMZ_CUSTOM_DIR}/plugins/zsh-autosuggestions" "${ZSH_AUTOSUGGESTIONS_TAG}"
clone_once https://github.com/lukechilds/zsh-nvm.git "${OMZ_CUSTOM_DIR}/plugins/zsh-nvm"

log_step "Installing tmux plugin manager (TPM)"
clone_once https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm" "${TPM_TAG}"

log_step "Linking configuration"
link_common "${DOTFILES_DIR}" linux

log_step "Setting login shell"
ZSH_PATH="/usr/bin/zsh"
if [ "$(getent passwd "${USER}" | cut -d: -f7)" = "${ZSH_PATH}" ]; then
  log_info "ok      ${ZSH_PATH}"
else
  log_info "chsh    ${USER} -> ${ZSH_PATH} (takes effect at next login)"
  run sudo chsh -s "${ZSH_PATH}" "${USER}"
fi

log_step "Done"
log_info "Start a new terminal (or log out and back in) to use zsh."
log_info "First zsh start installs nvm; in tmux press prefix + I to install plugins."
