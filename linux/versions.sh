# shellcheck shell=bash
# shellcheck disable=SC2034 # consumed by linux/packages.sh
# Pinned versions for tools not installed from an apt repository.
# To upgrade: bump the version and replace the sha256 with the value from the
# release's published checksum file (linked next to each entry).

# Kubernetes minor version for the pkgs.k8s.io apt repo (kubectl)
KUBERNETES_MINOR="v1.37"

# https://github.com/astral-sh/uv/releases (uv-x86_64-unknown-linux-gnu.tar.gz.sha256)
UV_VERSION="0.13.3"
UV_SHA256="e4f169ec380f1793b898a6f1fcbacd22db25cf7ca0349a6e96ffb85b69998d04"

# https://github.com/derailed/k9s/releases (checksums.sha256)
K9S_VERSION="v0.51.0"
K9S_SHA256="c3752ad51a5a4015a113819c4eeb6e55a4d0e4b8e652494797532f6fc8161dd7"

# Shell plugins (git tags)
PURE_TAG="v1.28.4"
ZSH_AUTOSUGGESTIONS_TAG="v0.7.1"
TPM_TAG="v3.1.0"
