# frozen_string_literal: true

# Standalone regression check for untrusted canonical URLs in link previews.
# A remote page may provide the preview metadata, but an unsafe canonical URL
# must fall back to the safe URL written in the post.

require "nokogiri"
require_relative "../_plugins/safe_link_preview_targets"

source_url = "https://example.com/article"
fixture_body = +<<~HTML
  <!doctype html>
  <html>
    <head>
      <meta property="og:title" content="Unsafe canonical">
      <meta property="og:type" content="article">
      <meta property="og:image" content="https://cdn.example.com/preview.png">
      <meta property="og:url" content="javascript:alert(document.domain)">
    </head>
  </html>
HTML

fixture_cache = Object.new
fixture_cache.define_singleton_method(:getset) do |_key, &block|
  block.call
end

fixture = Module.new do
  define_method(:oembed) do |_url|
    nil
  end

  define_method(:cache) do
    fixture_cache
  end

  define_method(:get) do |_url|
    Struct.new(:body).new(fixture_body)
  end
end
Jekyll::Embed.singleton_class.prepend(fixture)

config = Jekyll.configuration(
  "source" => File.expand_path("..", __dir__),
  "destination" => File.expand_path("../_site", __dir__)
)
Jekyll::Embed.site = Jekyll::Site.new(config)

safe_document = Nokogiri::HTML5.fragment(Jekyll::Embed.embed(source_url))
safe_link = safe_document.at_css("a.rich-link")

abort "Unsafe canonical URL remained clickable" unless safe_link["href"] == source_url
abort "Unsafe canonical URL remained visible" unless safe_link.at_css(".rich-link__url").text == source_url

canonical_url = "https://www.example.com/canonical"
fixture_body.sub!("javascript:alert(document.domain)", canonical_url)
canonical_document = Nokogiri::HTML5.fragment(Jekyll::Embed.embed("https://example.com/second-article"))
canonical_link = canonical_document.at_css("a.rich-link")

unless canonical_link["href"] == canonical_url
  abort "Valid HTTP(S) canonical URL was replaced with #{canonical_link['href'].inspect}"
end

puts "Link preview security check passed"
