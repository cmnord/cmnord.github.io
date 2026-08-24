# frozen_string_literal: true

# Makes link previews work for sites that stream Open Graph metadata after the
# document head. The pinned ogp parser only searches inside <head>, so this file
# moves otherwise valid metadata into the location it expects before parsing.

require "nokogiri"
require "ogp"
require "set"

module StreamedOpenGraphMetadata
  OPEN_GRAPH_SELECTOR = 'meta[property^="og:"]'

  def initialize(source, options = {})
    super(with_open_graph_tags_in_head(source), options)
  end

  private

  def with_open_graph_tags_in_head(source)
    document = Nokogiri::HTML(source)
    head = document.at_css("head")
    return source unless head

    head_properties = head.css(OPEN_GRAPH_SELECTOR).filter_map { |tag| tag["property"] }.to_set
    streamed_tags = document.css(OPEN_GRAPH_SELECTOR).reject do |tag|
      tag.ancestors.include?(head) || head_properties.include?(tag["property"])
    end
    return source if streamed_tags.empty?

    streamed_tags.each { |tag| head.add_child(tag.dup) }
    document.to_html
  end
end

OGP::OpenGraph.prepend(StreamedOpenGraphMetadata) unless OGP::OpenGraph < StreamedOpenGraphMetadata
