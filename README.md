# [clairenord.com](http://clairenord.com)

- Original theme: [Lagrange][lagrange]
- Design input: [Noah][noah]
- Design principles: [1][mfsite], [2][bettermfsite]
- Medium blog posts imported by [`medium-to-jekyll`][m2j]

## Setup

This project uses [mise][mise] to install and run the tools pinned in
`mise.toml`. Install and activate mise once, then run the setup script to
install Ruby, Bundler, [oxfmt][oxfmt], and the project's gems:

```sh
./scripts/setup.sh
```

Conductor workspaces bootstrap mise automatically when it is not already
installed.

## Development

Run `./scripts/serve.sh` and open <http://localhost:4000>.

To format, run `mise exec -- oxfmt .`. To run the same check CI runs:

```sh
mise exec -- oxfmt --check .
```

To verify a production build, run:

```sh
JEKYLL_ENV=production mise exec -- bundle exec jekyll build --strict_front_matter
```

## Newsletter publishing

After deploying to `main`, GitHub Actions sends newly published posts to Buttondown.
Create `BUTTONDOWN_API_KEY` with **Emails** and **Sending** write access.

Preview the email with:

```sh
mise exec -- bundle exec ruby scripts/publish-to-buttondown.rb \
  --output html _posts/your-post.md > /tmp/newsletter-preview.html
open /tmp/newsletter-preview.html
```

Use `--output json` to print the API payload. Jekyll posts with `published: false`
are not sent. Workflow retries are safe because Buttondown deduplicates each
request using a SHA-256 idempotency key derived from the post's canonical URL.

## License

Open sourced under the [MIT license][license].

[lagrange]: https://github.com/LeNPaul/Lagrange
[noah]: http://noahmoroze.com
[mfsite]: http://motherfuckingwebsite.com/
[bettermfsite]: http://bettermotherfuckingwebsite.com/
[m2j]: https://github.com/Donohue/medium-to-jekyll
[mise]: https://mise.jdx.dev/
[oxfmt]: https://github.com/oxc-project/oxc
[license]: https://github.com/cmnord/cmnord.github.io/blob/main/LICENSE.md
