# frozen_string_literal: true

module Archimate
  module DataModel
    # Model is the top level parent of an ArchiMate model.
    class Model < IdentifiedNode
      ARRAY_RE = Regexp.compile(/\[(\d+)\]/)

      # TODO: add metadata & property_defs as in Model Exchange Format
      attribute :name, Strict::String
      attribute :elements, Strict::Array.member(Element).default([])
      attribute :folders, Strict::Array.member(Folder).default([])
      attribute :relationships, Strict::Array.member(Relationship).default([])
      attribute :diagrams, Strict::Array.member(Diagram).default([])

      def initialize(attributes)
        super
        @index_hash = {}
        rebuild_index
        assign_model(self)
        assign_parent(nil)
      end

      def clone
        Model.new(
          id: id.clone,
          name: name.clone,
          documentation: documentation.map(&:clone),
          properties: properties.map(&:clone),
          elements: elements.map(&:clone),
          folders: folders.map(&:clone),
          relationships: relationships.map(&:clone),
          diagrams: diagrams.map(&:clone)
        )
      end

      def lookup(id)
        rebuild_index unless @index_hash.include?(id)
        @index_hash[id]
      end

      def register(node)
        @index_hash[node.id] = node
      end

      def find_by_class(klass)
        @index_hash.values.select { |item| item.is_a?(klass) }
      end

      def find_by_value(val)
        @index_hash.values.select { |item| val == item }
      end

      def to_s
        "#{AIO.data_model('Model')}<#{id}>[#{HighLine.color(name, [:white, :underline])}]"
      end

      # TODO: make these DSL like things added dynamically
      def application_components
        elements.select { |element| element.type == "ApplicationComponent" }
      end

      def element_type_names
        elements.map(&:type).uniq
      end

      def elements_with_type(el_type)
        elements.select { |element| element.type == el_type }
      end

      # TODO: make these DSL like things added dynamically
      def all_properties
        @index_hash.values.each_with_object([]) do |i, a|
          a.concat(i.properties) if i.respond_to?(:properties)
        end
      end

      # TODO: refactor to use property def structure instead of separate property objects
      def property_keys
        all_properties.map(&:key).uniq
      end

      # TODO: refactor to use property def structure instead of separate property objects
      def property_def_id(key)
        "propid-#{property_keys.index(key) + 1}"
      end

      # TODO: this adds no value, move directly to Difference
      # def apply_diff(diff)
      #   el = diff.target
      #   l_el = lookup_in_this_model(el)
      #   raise TypeError, "effective element #{el.class} != lookup element #{l_el.class}" unless l_el.is_a?(el.class)
      #   diff.apply(l_el)
      # end

      # def lookup_in_this_model(remote_element)
      #   if remote_element.respond_to?(:id)
      #     lookup(remote_element.id)
      #   elsif remote_element.is_a?(Array)
      #     send(remote_element.parent.attribute_name(remote_element))
      #   else
      #     raise TypeError, "Don't know how to look up #{remote_element.class} in #{self.class}"
      #   end
      # end

      private

      def rebuild_index
        @index_hash = build_index
      end
    end
  end
end
