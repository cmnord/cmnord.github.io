# frozen_string_literal: true

# Selects each post's explicitly marked inline hero image, or its first image as
# a fallback, for use in thumbnail previews and social metadata.
module Jekyll
  class HeroImageGenerator < Generator
    safe true
    priority :highest

    def generate(site)
      site.posts.docs.each do |post|
        images = find_images(Kramdown::Document.new(post.content).root)
        hero_images = images.select { |image| hero_image?(image) }

        validate_images(post, images, hero_images)

        image = hero_images.first || images.first
        post.data["image"] = {
          "path" => normalize_path(image.attr.fetch("src"), site),
          "alt" => image.attr["alt"]
        }
      end
    end

    private

    def find_images(element)
      images = image?(element) ? [element] : []
      element.children.each { |child| images.concat(find_images(child)) }
      images
    end

    def image?(element)
      (element.type == :img || (element.type == :html_element && element.value == "img")) && element.attr["src"]
    end

    def hero_image?(image)
      image.attr.fetch("class", "").split.include?("hero-image")
    end

    def validate_images(post, images, hero_images)
      if images.empty?
        Jekyll.logger.abort_with("Hero image:", "#{post.relative_path} must contain at least one image")
      end

      return unless hero_images.size > 1

      Jekyll.logger.abort_with("Hero image:", "#{post.relative_path} marks more than one .hero-image")
    end

    def normalize_path(path, site)
      path.gsub(/\{\{\s*site\.(?:github\.url|baseurl)\s*\}\}/, site.config["baseurl"].to_s)
    end
  end
end
