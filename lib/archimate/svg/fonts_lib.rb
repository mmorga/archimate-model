# frozen_string_literal: true

require "singleton"

module Archimate
  module Svg
    # This should be replaced with a portable alternative
    # I'm going to base this on fontconfig which should be fairly portable
    class FontsLib
      include Singleton

      DEFAULT_FONT_FACE = 'Lucida Grande'

      def font(font_face)
        cache.fetch(font_face&.strip || DEFAULT_FONT_FACE) do |face|
          cache[face] = Font.new(File.open(path_to(face), 'rb'))
        end
      end

      def path_to(font_face)
        path_cache.fetch(font_face&.strip || DEFAULT_FONT_FACE) { |face| lookup(face || DEFAULT_FONT_FACE) }
      end

      def lookup(font_face)
        fc_match = `fc-match "#{font_face}" file`
        file = fc_match.sub(/\A:file=/, "").strip
        path_cache[font_face] = file
        file
      end

      def cache
        @cache ||= {}
      end

      def path_cache
        @path_cache ||= {}
      end
    end
  end
end
