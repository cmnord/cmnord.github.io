# frozen_string_literal: true

# Regression check for the link-preview compatibility patch. Some frameworks
# stream Open Graph tags after </head>; the pinned parser normally misses them,
# which caused Every's preview image to disappear.

require "ogp"
require_relative "../_plugins/streamed_open_graph_metadata"

image_url = "https://cdn.example.com/preview.png"
streamed_document = <<~HTML
  <!doctype html>
  <html>
    <head><meta charset="utf-8"></head>
    <body>
      <h1>Streamed page</h1>
      <meta property="og:title" content="Streamed page">
      <meta property="og:type" content="article">
      <meta property="og:image" content="#{image_url}">
      <meta property="og:url" content="https://example.com/streamed-page">
    </body>
  </html>
HTML

open_graph = OGP::OpenGraph.new(streamed_document)
abort "Streamed Open Graph image was not discovered" unless open_graph.image&.url == image_url

standard_document = streamed_document.sub("</head>", streamed_document.scan(/<meta property="og:[^>]+>/).join("\n") + "\n</head>")
standard_open_graph = OGP::OpenGraph.new(standard_document)
abort "Standard Open Graph metadata was duplicated" unless standard_open_graph.title == "Streamed page"

puts "Streamed Open Graph metadata check passed"
