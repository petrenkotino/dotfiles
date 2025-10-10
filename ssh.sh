#!/bin/sh

set -e

if [ -z "${1:-}" ]; then
  echo "Usage: ./ssh.sh <email>"
  exit 1
fi

EMAIL="$1"
SSH_DIR="${HOME}/.ssh"
KEY_PATH="${SSH_DIR}/id_ed25519"
CONFIG_PATH="${SSH_DIR}/config"

echo "Generating a new SSH key for GitHub..."

mkdir -p "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

if [ -f "${KEY_PATH}" ]; then
  echo "Key ${KEY_PATH} already exists; skipping generation."
else
  ssh-keygen -t ed25519 -C "${EMAIL}" -f "${KEY_PATH}" -N ""
fi

eval "$(ssh-agent -s)"

touch "${CONFIG_PATH}"
chmod 600 "${CONFIG_PATH}"

if ! grep -q "IdentityFile ~/.ssh/id_ed25519" "${CONFIG_PATH}"; then
  cat <<'EOF' >> "${CONFIG_PATH}"
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
fi

ssh-add --apple-use-keychain "${KEY_PATH}"

echo "Run 'pbcopy < ~/.ssh/id_ed25519.pub' and paste that into GitHub."
