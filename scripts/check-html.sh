#!/usr/bin/env bash

# Validate generated HTML links, URL fragments, images, image alt text, and scripts.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

htmlproofer_ignored_urls=(
  # Business Wire closes the checker's HTTP/2 connection with an internal error.
  '/businesswire\.com/'
  # Google returns 410 to the checker for this intentionally preserved published deck.
  '/docs\.google\.com\/presentation/'

  # These MIT HKN sites present certificate chains the checker cannot validate.
  '/hkn\.mit\.edu/'
  '/hkn-tutoring2\.mit\.edu/'
  '/underground-guide\.mit\.edu/'

  # These domains reject automated link checks with status 403.
  '/medium\.com/'
  '/medical-dictionary\.thefreedictionary\.com/'
  '/scholar\.google\.com/'
  '/stackoverflow\.com/'

  # LinkedIn rejects automated link checks with status 999.
  '/linkedin\.com/'
  # Unsplash rejects automated link checks with status 401.
  '/unsplash\.com/'
)

htmlproofer_ignore_arg=$(IFS=,; echo "${htmlproofer_ignored_urls[*]}")
bundle exec htmlproofer ./_site \
  --no-ignore-empty-alt \
  --ignore-urls "$htmlproofer_ignore_arg"
