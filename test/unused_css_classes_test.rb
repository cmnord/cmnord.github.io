# frozen_string_literal: true

require_relative "test_helper"

require "set"
require "yaml"

class UnusedCssClassesTest < Minitest::Test
  REPO_ROOT = File.expand_path("..", __dir__)
  CSS_CLASS_PATTERN = /(?<![\w-])\.([a-zA-Z_][\w-]*)/
  CLASS_ATTRIBUTE_PATTERN = /\bclass\s*=\s*(["'])(.*?)\1/m
  CLASS_NAME_PATTERN = /[a-zA-Z_][\w-]*/
  KRAMDOWN_ATTRIBUTE_PATTERN = /\{:[^}]+\}/

  # Kramdown and Rouge create these selectors while rendering Markdown, so they
  # do not appear literally in source class attributes. Rouge's generated
  # syntax stylesheets are omitted below for the same reason.
  GENERATED_CLASSES = Set["footnote", "footnotes", "highlight", "reversefootnote"].freeze

  def test_authored_css_classes_are_referenced
    unused_classes = css_classes - referenced_classes - GENERATED_CLASSES

    assert_empty unused_classes, <<~MESSAGE
      Unused CSS class selectors: #{unused_classes.to_a.sort.join(", ")}
      Remove each selector or reference its class from markup or JavaScript.
    MESSAGE
  end

  private

  def css_classes
    stylesheet_paths.each_with_object(Set.new) do |path, classes|
      css = File.read(path).gsub(%r{/\*.*?\*/}m, "")
      css.scan(CSS_CLASS_PATTERN) { |match| classes << match.first }
    end
  end

  def referenced_classes
    markup_classes | markdown_classes | javascript_classes | configured_classes
  end

  def markup_classes
    markup_paths.each_with_object(Set.new) do |path, classes|
      File.read(path).scan(CLASS_ATTRIBUTE_PATTERN) do |_quote, value|
        value.scan(CLASS_NAME_PATTERN) { |class_name| classes << class_name }
      end
    end
  end

  def markdown_classes
    markdown_paths.each_with_object(Set.new) do |path, classes|
      File.read(path).scan(KRAMDOWN_ATTRIBUTE_PATTERN) do |attributes|
        attributes.scan(CSS_CLASS_PATTERN) { |match| classes << match.first }
      end
    end
  end

  def javascript_classes
    javascript = javascript_paths.map { |path| File.read(path) }.join("\n")

    css_classes.each_with_object(Set.new) do |class_name, classes|
      pattern = /(?<![\w-])#{Regexp.escape(class_name)}(?![\w-])/
      classes << class_name if javascript.match?(pattern)
    end
  end

  def configured_classes
    settings = YAML.safe_load_file(File.join(REPO_ROOT, "_data/settings.yml"))
    settings.fetch("social", []).each_with_object(Set.new) do |item, classes|
      classes << "fa-#{item.fetch("icon")}" if item["icon"]
    end
  end

  def stylesheet_paths
    Dir[File.join(REPO_ROOT, "_includes/css/*.css")].reject do |path|
      File.basename(path).start_with?("syntax")
    end
  end

  def markup_paths
    Dir[File.join(REPO_ROOT, "{_includes,_layouts,_posts,menu}/**/*.{html,md}")] +
      Dir[File.join(REPO_ROOT, "*.md")]
  end

  def markdown_paths
    Dir[File.join(REPO_ROOT, "{_posts,menu}/**/*.md")] + Dir[File.join(REPO_ROOT, "*.md")]
  end

  def javascript_paths
    Dir[File.join(REPO_ROOT, "assets/js/**/*.js")]
  end
end
