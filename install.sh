#!/usr/bin/env bash
# Entry point: dispatch to the platform installer, passing arguments through.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Darwin)
    exec "${DOTFILES_DIR}/macos/install.sh" "$@"
    ;;
  Linux)
    exec "${DOTFILES_DIR}/linux/install.sh" "$@"
    ;;
  *)
    echo "Unsupported operating system: $(uname -s)" >&2
    exit 1
    ;;
esac
