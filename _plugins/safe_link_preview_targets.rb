# frozen_string_literal: true

# A preview page controls its Open Graph canonical URL. The embed plugin strips
# unsafe targets during HTML cleanup, which would otherwise leave the card
# unclickable. Keep valid HTTP(S) canonicals; otherwise restore the URL written
# in the post.

require "jekyll"
require "jekyll-embed-urls"
require "nokogiri"
require "uri"

module SafeLinkPreviewTargets
  def embed(source_url)
    rendered = super
    return rendered unless http_url?(source_url)

    document = Nokogiri::HTML5.fragment(rendered)
    changed = false

    document.css("a.rich-link").each do |link|
      next if http_url?(link["href"])

      link["href"] = source_url
      link.at_css(".rich-link__url")&.content = source_url
      changed = true
    end

    changed ? document.to_html : rendered
  end

  private

  def http_url?(value)
    uri = URI.parse(value.to_s)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::Error
    false
  end
end

Jekyll::Embed.singleton_class.prepend(SafeLinkPreviewTargets) unless Jekyll::Embed.singleton_class < SafeLinkPreviewTargets
