#!/usr/bin/env ruby
# frozen_string_literal: true

require "jekyll"

repo_root = File.expand_path("..", __dir__)
site = Jekyll::Site.new(
  Jekyll.configuration("source" => repo_root, "quiet" => true, "unpublished" => true)
)
site.reset
site.read

markdown_files = site.pages.filter_map do |page|
  page.path if page.ext == ".md"
end
markdown_files.concat(site.collections.values.flat_map(&:docs).filter_map do |document|
  document.relative_path.delete_prefix("/") if document.extname == ".md"
end)
markdown_files.sort!

definition_pattern = /^\[([^\]^][^\]]*)\]:/
failures = []

markdown_files.each do |path|
  definitions = File.readlines(File.join(repo_root, path)).filter_map.with_index(1) do |line, line_number|
    match = line.match(definition_pattern)
    [match[1], line_number] if match
  end

  labels = definitions.map(&:first)
  expected = labels.sort_by { |label| label.downcase.gsub(/\s+/, " ").strip }
  next if labels == expected

  failures << <<~MESSAGE
    #{path}:#{definitions.first.last}: link definitions are not alphabetized
      actual:   #{labels.join(", ")}
      expected: #{expected.join(", ")}
  MESSAGE
end

if failures.any?
  warn failures.join("\n")
  exit 1
end

puts "Markdown link definitions are alphabetized (#{markdown_files.length} files checked)."
