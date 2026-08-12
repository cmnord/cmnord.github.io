#!/usr/bin/env bash

# Finds added posts and posts whose `published:` front matter changed between
# two Git revisions, then passes them to the Jekyll-aware Buttondown publisher.
# Jekyll filters out posts that remain unpublished. Extra arguments are passed
# to the publisher (for example, --output json).

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
modified=$(mktemp)
trap 'rm -f "$changes" "$modified"' EXIT

git diff --name-only --diff-filter=A -z \
  "$before" "$after" -- "${POST_PATHS[@]}" \
  > "$changes"
git diff --name-only --diff-filter=M -z -G '^[[:space:]]*published:' \
  "$before" "$after" -- "${POST_PATHS[@]}" \
  > "$modified"

while IFS= read -r -d '' post; do
  if git diff --unified=0 "$before" "$after" -- "$post" \
    | grep -Eiq '^-[[:space:]]*published:[[:space:]]*false([[:space:]]*(#.*)?)?$'; then
    printf '%s\0' "$post" >> "$changes"
  fi
done < "$modified"

mapfile -d '' -t posts < "$changes"

if (( ${#posts[@]} == 0 )); then
  echo "No newly added posts to publish."
  exit 0
fi

bundle exec ruby scripts/publish-to-buttondown.rb "$@" "${posts[@]}"
