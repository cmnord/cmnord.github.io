#!/usr/bin/env bash

# Finds posts added between two Git revisions and publishes them through the
# Jekyll-aware Buttondown publisher. Extra arguments are passed to the publisher
# (for example, --output json).

set -euo pipefail

readonly POST_PATHS=('_posts/*.md' '_posts/*.markdown' '_posts/*.html')

if (( $# < 2 )); then
  echo "Usage: scripts/publish-new-posts.sh BEFORE_SHA AFTER_SHA [--output json]" >&2
  exit 2
fi

before=$1
after=$2
shift 2

if [[ $before =~ ^0+$ ]]; then
  echo "No previous revision; skipping newsletter publishing."
  exit 0
fi

changes=$(mktemp)
trap 'rm -f "$changes"' EXIT

git diff --name-only --diff-filter=A -z \
  "$before" "$after" -- "${POST_PATHS[@]}" \
  > "$changes"
mapfile -d '' -t posts < "$changes"

if (( ${#posts[@]} == 0 )); then
  echo "No newly added posts to publish."
  exit 0
fi

bundle exec ruby scripts/publish-to-buttondown.rb "$@" "${posts[@]}"
