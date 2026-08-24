#!/usr/bin/env bash

# Validate generated HTML links, URL fragments, images, image alt text, and scripts.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

htmlproofer_ignored_urls=(
  # --- Status 0: transport-level failures ---

  # Business Wire closes the HTTP/2 connection with an internal error.
  '/businesswire\.com/'
  # This historical site works over HTTP but has no valid HTTPS endpoint.
  '/catb\.org/'
  # This archived MIT site intermittently times out in CI.
  '/d-lab\.mit\.edu/'
  # Automated link checks intermittently time out.
  '/goodreads\.com/'
  # This archived MIT site intermittently times out in CI.
  '/groups\.mit\.edu/'
  # This MIT HKN site presents an invalid certificate chain.
  '/hkn\.mit\.edu/'
  # This MIT HKN site presents an invalid certificate chain.
  '/hkn-tutoring2\.mit\.edu/'
  # This historical site works over HTTP but has no valid HTTPS endpoint.
  '/mobiletechnologylab\.org/'
  # This MIT HKN site presents an invalid certificate chain.
  '/underground-guide\.mit\.edu/'

  # --- Status 401: unauthorized ---

  # Unsplash rejects automated clients.
  '/unsplash\.com/'

  # --- Status 403: forbidden ---

  # Beaumont rejects automated clients.
  '/beaumont\.org/'
  # Fandom presents automated clients with a Cloudflare challenge.
  '/fandom\.com/'
  # Medium rejects automated clients.
  '/medium\.com/'
  # The Free Dictionary rejects automated clients.
  '/medical-dictionary\.thefreedictionary\.com/'
  # Google Scholar rejects automated clients.
  '/scholar\.google\.com/'
  # Stack Overflow rejects automated clients.
  '/stackoverflow\.com/'
  # Tizen rejects automated clients.
  '/tizen\.org/'

  # --- Status 405: method not allowed ---

  # MIT DSpace intermittently rejects automated requests.
  '/dspace\.mit\.edu/'

  # --- Status 429: too many requests ---

  # LessWrong rate-limits automated clients.
  '/lesswrong\.com/'
  # Hacker News rate-limits automated clients.
  '/news\.ycombinator\.com/'

  # --- Status 503: service unavailable ---

  # Waterpik intermittently rejects automated checks.
  '/waterpik\.com/'

  # --- Status 999: nonstandard request denial ---

  # LinkedIn rejects automated clients.
  '/linkedin\.com/'
)

htmlproofer_ignore_arg=$(IFS=,; echo "${htmlproofer_ignored_urls[*]}")
bundle exec htmlproofer ./_site \
  --no-ignore-empty-alt \
  --ignore-urls "$htmlproofer_ignore_arg"
