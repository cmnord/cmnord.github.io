#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

mise_bin="$(command -v mise || true)"
if [ -z "$mise_bin" ]; then
  mise_bin="$HOME/.local/bin/mise"
fi

if [ ! -x "$mise_bin" ]; then
  echo "mise is not installed; run ./scripts/setup.sh first" >&2
  exit 1
fi

port="${CONDUCTOR_PORT:-4000}"
exec "$mise_bin" exec -- bundle exec jekyll serve --livereload --port "$port"
