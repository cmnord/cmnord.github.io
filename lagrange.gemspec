# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "lagrange"
  spec.version       = "4.0.0"
  spec.authors       = ["Paul Le"]
  spec.email         = ["hello@paulle.ca"]

  spec.summary       = "A minimalist Jekyll theme for running a personal blog"
  spec.homepage      = "https://github.com/LeNPaul/Lagrange"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r!^(assets|_layouts|_includes|LICENSE|README|CHANGELOG)!i) }

  spec.add_runtime_dependency "jekyll", "~> 4.4"
  spec.add_runtime_dependency "jekyll-feed", "~> 0.17"
  spec.add_runtime_dependency "jekyll-sitemap", "~> 1.4"
  spec.add_runtime_dependency "jekyll-seo-tag", "~> 2.9"

end
