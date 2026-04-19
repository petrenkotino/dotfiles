#!/bin/sh

set -e

if [ -z "${1:-}" ]; then
  echo "Usage: ./ssh.sh <email> [suffix]"
  exit 1
fi

EMAIL="$1"
SUFFIX="${2:-}"
SSH_DIR="${HOME}/.ssh"

if [ -n "${SUFFIX}" ]; then
  KEY_NAME="id_ed25519_${SUFFIX}"
else
  KEY_NAME="id_ed25519"
fi

KEY_PATH="${SSH_DIR}/${KEY_NAME}"
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

if ! grep -q "IdentityFile ~/.ssh/${KEY_NAME}" "${CONFIG_PATH}"; then
  cat <<EOF >> "${CONFIG_PATH}"
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile "~/.ssh/${KEY_NAME}"
EOF
fi

ssh-add --apple-use-keychain "${KEY_PATH}"

echo "Run 'pbcopy < ${KEY_PATH}.pub' and paste that into GitHub."
