# frozen_string_literal: true

module Archimate
  module Svg
    # Converts a value in font units to px
    #
    # @see https://docs.microsoft.com/en-us/typography/opentype/spec/ttch01
    #
    # pointSize * resolution / ( 72 points per inch * units_per_em )
    #
    # where pointSize is the size at which the glyph is to be displayed, and
    # resolution is the resolution of the output device. The 72 in the
    # denominator reflects the number of points per inch.
    #
    # For example, assume that a glyph feature is 550 funits_per_em in length on
    # a 72 dpi screen at 18 point. There are 2048 units per em. The following
    # calculation reveals that the feature is 4.83 pixels long.
    #
    # 550 * 18 * 72 / ( 72 * 2048 ) = 4.83
    #
    # @see https://www.w3.org/TR/2008/REC-CSS2-20080411/syndata.html#length-units
    #
    class Text
      extend Forwardable

      def_delegators :@font, :line_height

      attr_reader :text
      attr_reader :font

      def initialize(text, style = nil)
        @text = text
        @font = FontsLib.instance.font(style&.font&.name)
        @font.style(style)
      end

      # TODO: Add a strategy to split by spaces & dashes & strip each line
      def layout_with_max(max_widths)
        split_by_word(text).each_with_object([[String.new, 0]]) do |str, lines|
          max_width = lines.length > max_widths.length ? max_widths.last : max_widths[lines.length - 1]
          if lines.last[0].empty?
            len = font.layout(str).width
            if len > max_width
              lines.pop
              lines.concat(layout_with_max_by_char(str, max_width))
              next
            end
            line_str = str
          else
            line_str = lines.last[0] + " " + str
            len = font.layout(line_str).width
            if len > max_width
              lines << [String.new, 0]
              len = font.layout(str).width
              line_str = str
            end
          end
          lines.last[0] = line_str
          lines.last[1] = len
        end
      end

      def split_by_word(str)
        str.split(/\s/)
      end

      def layout_with_max_by_char(str, max_width)
        str.chars.each_with_object([[String.new, 0]]) do |char, lines|
          len = font.layout(lines.last[0] + char).width
          if len > max_width
            lines << [String.new, 0]
            len = font.layout(char).width
          end
          lines.last[0] << char
          lines.last[1] = len
        end
      end
    end
  end
end
