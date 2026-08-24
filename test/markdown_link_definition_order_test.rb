# frozen_string_literal: true

require_relative "test_helper"

require "jekyll"

class MarkdownLinkDefinitionOrderTest < Minitest::Test
  DEFINITION_PATTERN = /^\[([^\]^][^\]]*)\]:/
  REPO_ROOT = File.expand_path("..", __dir__)

  def test_link_definitions_are_alphabetized
    failures = markdown_files.filter_map do |path|
      definitions = definitions_in(path)
      labels = definitions.map(&:first)
      expected = labels.sort_by { |label| label.downcase.gsub(/\s+/, " ").strip }
      next if labels == expected

      <<~MESSAGE
        #{path}:#{definitions.first.last}: link definitions are not alphabetized
          actual:   #{labels.join(", ")}
          expected: #{expected.join(", ")}
      MESSAGE
    end

    assert_empty failures, failures.join("\n")
  end

  private

  def definitions_in(path)
    File.readlines(File.join(REPO_ROOT, path)).filter_map.with_index(1) do |line, line_number|
      match = line.match(DEFINITION_PATTERN)
      [match[1], line_number] if match
    end
  end

  def markdown_files
    site = Jekyll::Site.new(
      Jekyll.configuration("source" => REPO_ROOT, "quiet" => true, "unpublished" => true)
    )
    site.reset
    site.read

    pages = site.pages.filter_map do |page|
      page.path if page.ext == ".md"
    end
    documents = site.collections.values.flat_map(&:docs).filter_map do |document|
      document.relative_path.delete_prefix("/") if document.extname == ".md"
    end
    pages.concat(documents).sort
  end
end
