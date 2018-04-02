# frozen_string_literal: true

require 'harfbuzz'

module Archimate
  module Svg
    # TODO: Set up a means to establish defaults for font, etc.
    class Font
      # SVG 1.1 Spec recommends a reference pixel use a DPI of 90, but it would
      # seem that Archi's ArchiMate renderer defaults to 72 DPI.
      REFERENCE_DPI = 72.0

      attr_reader :line_height
      attr_reader :font
      attr_reader :face

      def initialize(font_blob)
        @face = Harfbuzz::Face.new(font_blob)
        @font = Harfbuzz::Font.new(face)
        style(nil)
      end

      def style(with_style)
        font_size_px = with_style&.font&.size || 11.0
        @line_height = 1.4 * font_size_px
        @funits_scale = font_size_px * REFERENCE_DPI / (72.0 * face.upem.to_f)
      end

      def font_to_px(font_units)
        font_units * @funits_scale
      end

      def layout(text)
        return DataModel::Bounds.zero if text.strip.empty?
        buffer = Harfbuzz::Buffer.new
        buffer.add_utf8(text.to_s.encode('utf-8'))
        buffer.guess_segment_properties
        Harfbuzz.shape(font, buffer, %w[+ccmp +kern])
        buffer.normalize_glyphs
        buffer
          .get_glyph_positions
          .reduce(
            DataModel::Bounds.new(x: 0, y: 0, width: 0, height: line_height)
          ) do |bounds, gp|
          DataModel::Bounds.new(
            x: bounds.x,
            y: bounds.y,
            width: bounds.width + font_to_px(gp.x_offset + gp.x_advance),
            height: bounds.height
          )
        end
      end
    end
  end
end
