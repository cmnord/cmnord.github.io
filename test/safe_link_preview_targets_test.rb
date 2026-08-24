# frozen_string_literal: true

require_relative "test_helper"

require "nokogiri"
require_relative "../_plugins/safe_link_preview_targets"

module LinkPreviewFixture
  class << self
    attr_accessor :body
  end

  def oembed(_url)
    nil
  end

  def cache
    @fixture_cache ||= Object.new.tap do |cache|
      cache.define_singleton_method(:getset) do |_key, &block|
        block.call
      end
    end
  end

  def get(_url)
    Struct.new(:body).new(LinkPreviewFixture.body)
  end
end

Jekyll::Embed.singleton_class.prepend(LinkPreviewFixture) unless Jekyll::Embed.singleton_class < LinkPreviewFixture

class SafeLinkPreviewTargetsTest < Minitest::Test
  SOURCE_URL = "https://example.com/article"

  def setup
    config = Jekyll.configuration(
      "source" => File.expand_path("..", __dir__),
      "destination" => File.expand_path("../_site", __dir__)
    )
    Jekyll::Embed.site = Jekyll::Site.new(config)
  end

  def test_unsafe_canonical_url_falls_back_to_source_url
    link = render_preview("javascript:alert(document.domain)")

    assert_equal SOURCE_URL, link["href"]
    assert_equal SOURCE_URL, link.at_css(".rich-link__url").text
  end

  def test_valid_http_canonical_url_is_preserved
    canonical_url = "https://www.example.com/canonical"

    assert_equal canonical_url, render_preview(canonical_url)["href"]
  end

  private

  def render_preview(canonical_url)
    LinkPreviewFixture.body = <<~HTML
      <!doctype html>
      <html>
        <head>
          <meta property="og:title" content="Canonical URL">
          <meta property="og:type" content="article">
          <meta property="og:image" content="https://cdn.example.com/preview.png">
          <meta property="og:url" content="#{canonical_url}">
        </head>
      </html>
    HTML

    document = Nokogiri::HTML5.fragment(Jekyll::Embed.embed(SOURCE_URL))
    document.at_css("a.rich-link")
  end
end
