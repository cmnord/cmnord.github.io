#!/usr/bin/env ruby
# frozen_string_literal: true

# This intentionally uses Ruby so the publisher can ask Jekyll to render posts
# exactly as the site does. A shell version would need to reimplement or parse
# Jekyll's front matter, Liquid, Markdown, permalinks, HTML, and JSON escaping.

require "digest"
require "cgi"
require "json"
require "net/http"
require "nokogiri"
require "optparse"
require "uri"

require "jekyll"

API_URL = URI("https://api.buttondown.com/v1/emails")
# Buttondown reads this leading sentinel and stores the body as rich HTML (its
# "Fancy" editor mode) instead of interpreting the rendered post as Markdown.
EDITOR_MODE = "<!-- buttondown-editor-mode: fancy -->"
OUTPUT_FORMATS = %w[html json].freeze
ROUGE_EMAIL_DEFAULT_STYLE = "color: #f8f8f2 !important"

# Buttondown's Modern template uses a dark background for code blocks. Rouge's
# token classes need inline colors because custom newsletter CSS is not
# available on Buttondown's free plan and Buttondown's CSS inliner otherwise
# gives the spans the surrounding text color.
ROUGE_EMAIL_STYLES = {
  "color: #f8f8f2 !important" => %w[bp n ni nn nv nx p py vc vg vi vm w],
  "color: #f8f8f2 !important; font-weight: bold" => %w[nl],
  "color: #a6a1c4 !important; font-style: italic" => %w[c c1 cd ch cm cp cpf cs],
  "color: #a6a1c4 !important" => %w[gl],
  "color: #cfcfc2 !important" => %w[go],
  "color: #66d9ef !important" => %w[gp kt no],
  "color: #66d9ef !important; font-weight: bold" => %w[gh gu],
  "color: #ff6188 !important" => %w[gd gr gt nt o],
  "color: #ff6188 !important; font-weight: bold" => %w[k kd kn kp kr kv ow],
  "color: #a9dc76 !important" => %w[gi na nb nd nf],
  "color: #a9dc76 !important; font-weight: bold" => %w[nc ne],
  "color: #ab9df2 !important" => %w[kc l m mb mf mh mi mo mx se],
  "color: #e6db74 !important" => %w[dl ld s s1 s2 sa sb sc sd sh si sr ss sx],
  "color: #f8f8f2 !important; background-color: #a71930" => %w[err],
  "font-style: italic" => %w[ge],
  "font-style: italic; font-weight: bold" => %w[ges],
  "font-weight: bold" => %w[gs],
}.each_with_object({}) do |(style, token_names), styles|
  token_names.each { |name| styles[name] = style }
end.freeze

options = {
  output: nil,
}

OptionParser.new do |parser|
  parser.banner = "Usage: scripts/publish-to-buttondown.rb [options] [_posts/post.md ...]"
  parser.on("--output FORMAT", OUTPUT_FORMATS, "Render without publishing: html or json") do |format|
    options[:output] = format
  end
end.parse!

def absolute_url(base_url, value)
  uri = URI(value)
  return value if uri.absolute? || value.start_with?("#")

  URI.join(base_url, value).to_s
rescue URI::InvalidURIError
  value
end

# Adapts a Jekyll-rendered page for Buttondown's rich-HTML editor. This is not a
# full HTML-to-email conversion: it extracts the post article and makes relative
# links and images portable outside the website. Buttondown applies the actual
# newsletter template and email-client compatibility styles.
def email_body(post, canonical_url)
  page = Nokogiri::HTML5(post.output)
  article = page.at_css("article.post-content")
  abort "Could not find the rendered post body for #{post.relative_path}." unless article

  # Preserve Rouge's highlighting without relying on paid custom CSS. The
  # !important colors survive Buttondown's universal text-color rule.
  article.css("pre code span").each do |span|
    styles = span["class"].to_s.split.filter_map { |name| ROUGE_EMAIL_STYLES[name] }
    styles.unshift(ROUGE_EMAIL_DEFAULT_STYLE) unless styles.any? { |style| style.include?("color:") }
    span["style"] = styles.join("; ")
  end

  # Jekyll wraps each block in two divs that are useful on the website but can
  # leak into Buttondown's generated plain-text part. Send simple, semantic
  # pre/code markup instead, retaining the language on the code element.
  article.css("div.highlighter-rouge").each do |wrapper|
    pre = wrapper.at_css("pre")
    code = pre&.at_css("code")
    next unless pre && code

    language = wrapper["class"].to_s.split.find { |name| name.start_with?("language-") }
    code["class"] = [code["class"], language].compact.join(" ") if language
    pre.remove_attribute("class")
    wrapper.replace(pre.unlink)
  end

  article.css("a[href]").each do |link|
    link["href"] = absolute_url(canonical_url, link["href"])
  end
  article.css("img[src]").each do |image|
    image["src"] = absolute_url(canonical_url, image["src"])
  end

  source_name = URI(canonical_url).host&.delete_prefix("www.") || canonical_url
  source_link = <<~HTML.strip
    <p style="font-size: 13px !important; line-height: 18px !important; margin-top: 0 !important; text-align: right;">
      <a href="#{CGI.escapeHTML(canonical_url)}">Read original on #{CGI.escapeHTML(source_name)} →</a>
    </p>
  HTML

  "#{EDITOR_MODE}\n#{source_link}\n#{article.inner_html.strip}\n"
end

# Wraps the body in only enough markup to open it in a browser. This deliberately
# adds no styling because Buttondown applies the actual template when sending.
def preview_document(payload)
  body = payload.fetch(:body).delete_prefix("#{EDITOR_MODE}\n")
  subject = CGI.escapeHTML(payload.fetch(:subject).to_s)

  <<~HTML
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Preview: #{subject}</title>
      </head>
      <body>
        <main>
          #{body}
        </main>
      </body>
    </html>
  HTML
end

def image_url(site_url, post)
  image = post.data["image"]
  value = image.is_a?(Hash) ? image["path"] : image
  value ? absolute_url(site_url, value) : ""
end

paths = ARGV.uniq

abort "HTML output accepts exactly one post." if options[:output] == "html" && paths.length != 1

if paths.empty?
  puts "No newly added posts to publish."
  exit
end

unless options[:output] || ENV["BUTTONDOWN_API_KEY"]&.length&.positive?
  abort "BUTTONDOWN_API_KEY is required to publish an email."
end

config = Jekyll.configuration(
  "environment" => "production",
  "quiet" => true,
  "strict_front_matter" => true,
)
site = Jekyll::Site.new(config)
site.process

paths.each do |path|
  relative_path = path.delete_prefix("./").delete_prefix("/")
  post = site.posts.docs.find { |candidate| candidate.relative_path.delete_prefix("/") == relative_path }

  unless post
    warn "Skipping #{path}: it is not a published Jekyll post."
    next
  end
  canonical_url = URI.join(site.config.fetch("url"), post.url).to_s
  payload = {
    subject: post.data.fetch("title"),
    body: email_body(post, canonical_url),
    canonical_url: canonical_url,
    description: post.data.fetch("description", ""),
    image: image_url(site.config.fetch("url"), post),
    status: "about_to_send",
    metadata: {
      source: "github_actions",
      source_path: path,
      source_commit: ENV.fetch("GITHUB_SHA", "local"),
    },
  }

  if options[:output] == "json"
    puts JSON.pretty_generate(payload)
    next
  end

  if options[:output] == "html"
    puts preview_document(payload)
    next
  end

  request = Net::HTTP::Post.new(API_URL)
  request["Authorization"] = "Token #{ENV.fetch("BUTTONDOWN_API_KEY")}"
  request["Content-Type"] = "application/json"
  # Buttondown requires this explicit confirmation when an API key first queues
  # an email for sending; it prevents an accidental first live send.
  request["X-Buttondown-Live-Dangerously"] = "true"
  # Buttondown deduplicates requests with the same X-Idempotency-Key. Deriving
  # it from the canonical URL makes workflow retries safe for each stable post.
  request["X-Idempotency-Key"] = Digest::SHA256.hexdigest(canonical_url)
  request.body = JSON.generate(payload)

  response = Net::HTTP.start(API_URL.hostname, API_URL.port, use_ssl: true) do |http|
    http.request(request)
  end

  unless response.is_a?(Net::HTTPSuccess)
    abort "Buttondown rejected #{path} (HTTP #{response.code}): #{response.body}"
  end

  result = JSON.parse(response.body)
  puts "Queued #{path} for sending as #{result.fetch("id", "an email")}."
end
