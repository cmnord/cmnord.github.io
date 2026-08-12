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
