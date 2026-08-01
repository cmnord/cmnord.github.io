# [clairenord.com](http://clairenord.com)

- Original theme: [Lagrange][lagrange]
- Design input: [Noah][noah]
- Design principles: [1][mfsite], [2][bettermfsite]
- Medium blog posts imported by [`medium-to-jekyll`][m2j]

## Setup

1. Install the [Ruby][ruby] version in `.ruby-version`.
2. Install [Bundler][bundler].
3. Run `bundle install`.

## Development

Run `bundle exec jekyll serve --livereload` and open <http://localhost:4000>.

To verify a production build, run:

```sh
JEKYLL_ENV=production bundle exec jekyll build --strict_front_matter
```

## License

Open sourced under the [MIT license][license].

[lagrange]: https://github.com/LeNPaul/Lagrange
[noah]: http://noahmoroze.com
[mfsite]: http://motherfuckingwebsite.com/
[bettermfsite]: http://bettermotherfuckingwebsite.com/
[m2j]: https://github.com/Donohue/medium-to-jekyll
[ruby]: https://www.ruby-lang.org/en/documentation/installation/
[bundler]: https://bundler.io/
[license]: https://github.com/cmnord/cmnord.github.io/blob/main/LICENSE.md
