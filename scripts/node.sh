#!/bin/bash
# This script is intended to fix the version issue with Node.js.
# Apparently, GitHub Codespaces (from what I can tell) comes installed with an older
# version of Node.js, so let's just reinstall it!
#
# Requirements:
# ~ NVM (Node Version Manager, installed with Node.js)

set -euo pipefail

if [ ! -d "$HOME/.nvm" ] && [ ! -d "/usr/local/share/nvm" ]; then
  echo "NVM not found. Installing..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"
elif [ -d "/usr/local/share/nvm" ]; then
  export NVM_DIR="/usr/local/share/nvm"
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

if ! command -v node >/dev/null 2>&1; then
  nvm install node
else
  nvm use node >/dev/null || nvm install node
fi

echo "Node.js ready: $(node -v)"

if ! command -v pnpm >/dev/null 2>&1; then
  npm install -g pnpm
fi

echo "PNPM ready: $(pnpm --version)"