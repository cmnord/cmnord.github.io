# frozen_string_literal: true

require_relative "test_helper"

require "ogp"
require_relative "../_plugins/streamed_open_graph_metadata"

class StreamedOpenGraphMetadataTest < Minitest::Test
  IMAGE_URL = "https://cdn.example.com/preview.png"
  OPEN_GRAPH_TAGS = <<~HTML
    <meta property="og:title" content="Streamed page">
    <meta property="og:type" content="article">
    <meta property="og:image" content="#{IMAGE_URL}">
    <meta property="og:url" content="https://example.com/streamed-page">
  HTML

  def test_discovers_open_graph_image_streamed_after_head
    open_graph = OGP::OpenGraph.new(document_with(OPEN_GRAPH_TAGS))

    assert_equal IMAGE_URL, open_graph.image&.url
  end

  def test_preserves_standard_open_graph_metadata
    open_graph = OGP::OpenGraph.new(document_with(OPEN_GRAPH_TAGS, head: OPEN_GRAPH_TAGS))

    assert_equal "Streamed page", open_graph.title
  end

  private

  def document_with(body_metadata, head: nil)
    <<~HTML
      <!doctype html>
      <html>
        <head>
          <meta charset="utf-8">
          #{head}
        </head>
        <body>
          <h1>Streamed page</h1>
          #{body_metadata}
        </body>
      </html>
    HTML
  end
end
