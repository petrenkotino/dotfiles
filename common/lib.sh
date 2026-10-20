# shellcheck shell=sh
# Shared helpers, sourced by macos/install.sh and linux/install.sh.
# POSIX sh so the macOS installer can keep using /bin/sh.

DRY_RUN="${DRY_RUN:-0}"

log_step() {
  printf '\n==> %s\n' "$1"
}

log_info() {
  printf '    %s\n' "$1"
}

die() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

# run <cmd> [args...]: execute, or only print it when DRY_RUN=1
run() {
  if [ "${DRY_RUN}" = "1" ]; then
    printf '    [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

# link <source> <target>: point target at source.
# A real file/dir at target is moved to <target>.bak.<timestamp> first;
# an existing (possibly dangling) symlink is simply replaced.
link() {
  _src="$1"
  _dest="$2"
  [ -e "${_src}" ] || die "link source missing: ${_src}"

  if [ -L "${_dest}" ] && [ "$(readlink "${_dest}")" = "${_src}" ]; then
    log_info "ok      ${_dest}"
    return 0
  fi

  [ -d "$(dirname "${_dest}")" ] || run mkdir -p "$(dirname "${_dest}")"

  if [ -e "${_dest}" ] && [ ! -L "${_dest}" ]; then
    _backup="${_dest}.bak.$(date +%Y%m%d%H%M%S)"
    log_info "backup  ${_dest} -> ${_backup}"
    run mv "${_dest}" "${_backup}"
  fi

  log_info "link    ${_dest} -> ${_src}"
  run ln -sfn "${_src}" "${_dest}"
}

# clone_once <url> <dir> [tag]: shallow clone unless dir already exists
clone_once() {
  if [ -d "$2" ]; then
    log_info "present $2"
    return 0
  fi
  log_info "clone   $1 ${3:+($3)}"
  if [ -n "${3:-}" ]; then
    run git -c advice.detachedHead=false clone --quiet --depth=1 --branch "$3" "$1" "$2"
  else
    run git clone --quiet --depth=1 "$1" "$2"
  fi
}

# link_common <dotfiles_dir> <os_dir>: symlinks shared by every platform
link_common() {
  link "$1/common/zsh/.zshrc" "${HOME}/.zshrc"
  link "$1/common/.tmux.conf" "${HOME}/.tmux.conf"
  link "$1/common/vim/vimrc" "${HOME}/.vimrc"
  link "$1/common/nvim" "${HOME}/.config/nvim"
  link "$1/common/zsh/path.zsh" "${HOME}/.zsh/custom/path.zsh"
  link "$1/common/zsh/aliases.zsh" "${HOME}/.zsh/custom/aliases.zsh"
  link "$1/$2/aliases.zsh" "${HOME}/.zsh/custom/aliases-os.zsh"

  for _script in "$1"/bin/*; do
    [ -x "${_script}" ] || run chmod +x "${_script}"
    link "${_script}" "${HOME}/bin/$(basename "${_script}")"
  done
}
