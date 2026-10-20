# shellcheck shell=bash
# shellcheck disable=SC2034 # package lists are consumed by linux/install.sh
# Package lists and installers for Ubuntu. Sourced by linux/install.sh.
# Requires common/lib.sh and linux/versions.sh to be sourced first.

# Essential: installed by every profile
BASE_PACKAGES=(
  zsh git curl wget make build-essential ca-certificates gnupg unzip
  tmux neovim fzf ripgrep bat fd-find jq
)

# Optional developer tooling (--profile dev). gh/kubectl/helm/tofu come from
# the vendor apt repositories added in add_dev_repos.
DEV_PACKAGES=(
  direnv golang-go
  gh kubectl helm tofu
)

KEYRING_DIR="/etc/apt/keyrings"
SOURCES_DIR="/etc/apt/sources.list.d"
# Refresh package lists once per run, before the first install that needs it
APT_NEEDS_UPDATE=1

# apt_install <pkg>...: install only packages that are not already present
apt_install() {
  local missing=() pkg
  for pkg in "$@"; do
    if dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | grep -q "install ok installed"; then
      log_info "ok      ${pkg}"
    else
      missing+=("${pkg}")
    fi
  done
  [ "${#missing[@]}" -eq 0 ] && return 0

  if [ "${APT_NEEDS_UPDATE}" = "1" ]; then
    run sudo apt-get update
    APT_NEEDS_UPDATE=0
  fi
  log_info "install ${missing[*]}"
  run sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${missing[@]}"
}

# apt_upgrade <pkg>...: upgrade already-installed packages (not-installed ones are left to apt_install)
apt_upgrade() {
  if [ "${APT_NEEDS_UPDATE}" = "1" ]; then
    run sudo apt-get update
    APT_NEEDS_UPDATE=0
  fi
  log_info "upgrade $*"
  run sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --only-upgrade "$@"
}

# add_apt_key <name> <url>: store a (possibly ASCII-armored) key as a binary keyring
add_apt_key() {
  local dest="${KEYRING_DIR}/$1.gpg" tmp
  if [ -s "${dest}" ]; then
    log_info "ok      ${dest}"
    return 0
  fi
  log_info "key     $2 -> ${dest}"
  if [ "${DRY_RUN}" = "1" ]; then
    printf '    [dry-run] fetch %s, dearmor if needed, install to %s\n' "$2" "${dest}"
    return 0
  fi
  tmp="$(mktemp)"
  curl -fsSL "$2" -o "${tmp}"
  if head -c 5 "${tmp}" | grep -q -- '-----'; then
    gpg --batch --yes --dearmor -o "${tmp}.gpg" "${tmp}"
    mv "${tmp}.gpg" "${tmp}"
  fi
  sudo install -d -m 0755 "${KEYRING_DIR}"
  sudo install -m 0644 "${tmp}" "${dest}"
  rm -f "${tmp}"
}

# add_apt_source <name> <deb line>: (re)write the sources file only if it changed
add_apt_source() {
  local dest="${SOURCES_DIR}/$1.list"
  if [ -f "${dest}" ] && [ "$(cat "${dest}")" = "$2" ]; then
    log_info "ok      ${dest}"
    return 0
  fi
  log_info "source  ${dest}"
  run sudo sh -c 'printf "%s\n" "$1" > "$2"' _ "$2" "${dest}"
  APT_NEEDS_UPDATE=1
}

add_dev_repos() {
  local arch
  arch="$(dpkg --print-architecture)"

  # GitHub CLI - https://github.com/cli/cli/blob/trunk/docs/install_linux.md
  add_apt_key githubcli https://cli.github.com/packages/githubcli-archive-keyring.gpg
  add_apt_source github-cli "deb [arch=${arch} signed-by=${KEYRING_DIR}/githubcli.gpg] https://cli.github.com/packages stable main"

  # kubectl - https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
  # The repo and key are per minor version, so a version bump replaces both and
  # upgrades an existing kubectl (apt_install alone would skip it as installed).
  local k8s_minor_changed=0
  if [ -f "${SOURCES_DIR}/kubernetes.list" ] && ! grep -q "/${KUBERNETES_MINOR}/" "${SOURCES_DIR}/kubernetes.list"; then
    k8s_minor_changed=1
  fi
  if [ ! -f "${SOURCES_DIR}/kubernetes.list" ] || [ "${k8s_minor_changed}" = "1" ]; then
    [ -f "${KEYRING_DIR}/kubernetes.gpg" ] && run sudo rm -f "${KEYRING_DIR}/kubernetes.gpg"
  fi
  add_apt_key kubernetes "https://pkgs.k8s.io/core:/stable:/${KUBERNETES_MINOR}/deb/Release.key"
  add_apt_source kubernetes "deb [signed-by=${KEYRING_DIR}/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/${KUBERNETES_MINOR}/deb/ /"
  if [ "${k8s_minor_changed}" = "1" ]; then
    apt_upgrade kubectl
  fi

  # Helm - https://helm.sh/docs/intro/install/#from-apt-debianubuntu
  add_apt_key helm https://packages.buildkite.com/helm-linux/helm-debian/gpgkey
  add_apt_source helm "deb [signed-by=${KEYRING_DIR}/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main"

  # OpenTofu - https://opentofu.org/docs/intro/install/deb/
  add_apt_key opentofu https://get.opentofu.org/opentofu.gpg
  add_apt_key opentofu-repo https://packages.opentofu.org/opentofu/tofu/gpgkey
  add_apt_source opentofu "deb [signed-by=${KEYRING_DIR}/opentofu.gpg,${KEYRING_DIR}/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main"
}

# reported_version <cmd> [args...]: first version-looking token the command
# prints (e.g. "uv 0.13.3 (...)" -> 0.13.3, "Version  v0.51.0" -> 0.51.0)
reported_version() {
  "$@" 2>/dev/null | grep -oE 'v?[0-9]+(\.[0-9]+)+(-[0-9A-Za-z.]+)?' | head -n 1 | sed 's/^v//'
}

# install_tarball <bin> <version> <url> <sha256> <version args...>: verified
# install into ~/.local/bin, skipped when `<bin> <version args>` reports exactly <version>.
# Every executable in the tarball (top level or one dir down) whose name starts
# with <bin> is installed, which picks up both uv and uvx.
install_tarball() {
  local bin="$1" version="$2" url="$3" sha="$4" dest="${HOME}/.local/bin" tmp
  shift 4
  if [ -x "${dest}/${bin}" ] && [ "$(reported_version "${dest}/${bin}" "$@")" = "${version#v}" ]; then
    log_info "ok      ${bin} ${version}"
    return 0
  fi
  log_info "install ${bin} ${version}"
  if [ "${DRY_RUN}" = "1" ]; then
    printf '    [dry-run] fetch %s, verify sha256 %s, install to %s\n' "${url}" "${sha}" "${dest}"
    return 0
  fi
  tmp="$(mktemp -d)"
  curl -fsSL "${url}" -o "${tmp}/pkg.tar.gz"
  echo "${sha}  ${tmp}/pkg.tar.gz" | sha256sum --check --status \
    || { rm -rf "${tmp}"; die "checksum mismatch for ${url}"; }
  tar -xzf "${tmp}/pkg.tar.gz" -C "${tmp}"
  mkdir -p "${dest}"
  find "${tmp}" -maxdepth 2 -type f -name "${bin}*" -perm -u+x -exec install -m 0755 {} "${dest}/" \;
  rm -rf "${tmp}"
}

install_dev_binaries() {
  [ "$(dpkg --print-architecture)" = "amd64" ] || die "pinned release binaries are amd64-only; see linux/versions.sh"

  install_tarball uv "${UV_VERSION}" \
    "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-x86_64-unknown-linux-gnu.tar.gz" \
    "${UV_SHA256}" --version
  install_tarball k9s "${K9S_VERSION}" \
    "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" \
    "${K9S_SHA256}" version --short
}
