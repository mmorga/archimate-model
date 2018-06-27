# frozen_string_literal: true

# The color module is a hook to allow other archimate extensions to apply
# coloring in an adaptable way. The defaults here do nothing.

module Archimate
  class Color
    def self.layer_color(layer, str)
      sym = layer&.to_sym
      color(str, sym)
    end

    def self.data_model(str)
      layer_color(str, str)
    end

    def self.color(str, args)
      str
    end

    def self.uncolor(str)
      str
    end
  end
end
