#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [ "${CONDUCTOR_IS_LOCAL:-}" = "0" ] && command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y gcc gcc-c++ make
fi

mise_bin="$(command -v mise || true)"
if [ -z "$mise_bin" ]; then
  mise_bin="$HOME/.local/bin/mise"
  if [ ! -x "$mise_bin" ]; then
    curl --proto '=https' --tlsv1.2 -fsSL https://mise.run | sh
  fi
fi

"$mise_bin" trust
MISE_RUBY_COMPILE=false "$mise_bin" install
"$mise_bin" exec -- gem install bundler --version 4.0.17
"$mise_bin" exec -- bundle install
