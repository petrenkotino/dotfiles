
# Local bin directories before anything else
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# Load custom commands
# Add user bin directories to PATH if not already present:
#   ~/go/bin     - `go install` binaries
#   ~/.local/bin - uv, uv tool shims, k9s (Linux)
#   ~/bin        - scripts from ~/.dotfiles/bin
for dir in "$HOME/go/bin" "$HOME/.local/bin" "$HOME/bin"; do
  if [ -d "$dir" ] && [[ ":$PATH:" != *":$dir:"* ]]; then
    export PATH="$dir:$PATH"
  fi
done
unset dir
