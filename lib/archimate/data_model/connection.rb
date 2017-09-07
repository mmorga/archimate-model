# frozen_string_literal: true

module Archimate
  module DataModel
    # Graphical connection type.
    #
    # If the 'relationshipRef' attribute is present, the connection should reference an existing ArchiMate relationship.
    #
    # If the connection is an ArchiMate relationship type, the connection's label, documentation and properties may be determined
    # (i.e inherited) from those in the referenced ArchiMate relationship. Otherwise the connection's label, documentation and properties
    # can be provided and will be additional to (or over-ride) those contained in the referenced ArchiMate relationship.
    # ViewConceptType
    # - ConnectionType(
    #     sourceAttachment
    #     bendpoint
    #     targetAttachment
    #     source
    #     target)
    class Connection
      include Comparison

      # @return [String]
      model_attr :id
      # @return [LangString, NilClass]
      model_attr :name
      # @return [PreservedLangString, NilClass]
      model_attr :documentation
      # # @return [Array<AnyElement>]
      model_attr :other_elements
      # # @return [Array<AnyAttribute>]
      model_attr :other_attributes
      # @note type here was used for the Element/Relationship/Diagram type
      # @return [String, NilClass]
      model_attr :type
      # @return [Location, NilClass]
      model_attr :source_attachment
      # @return [Array<Location>]
      model_attr :bendpoints
      # @return [Location, NilClass]
      model_attr :target_attachment
      # @return [ViewNode, NilClass]
      model_attr :source, comparison_attr: :id, writable: true
      # @return [ViewNode, NilClass]
      model_attr :target, comparison_attr: :id, writable: true
      # @return [Relationship, NilClass]
      model_attr :relationship, comparison_attr: :id, writable: true
      # @return [Style, NilClass]
      model_attr :style
      # @return [Array<Property>]
      model_attr :properties

      def initialize(id:, name: nil, documentation: nil, type: nil,
                     source_attachment: nil, bendpoints: [], target_attachment: nil,
                     source: nil, target: nil, relationship: nil, style: nil,
                     properties: nil)
        @id = id
        @name = name
        @documentation = documentation
        @type = type
        @source_attachment = source_attachment
        @bendpoints = bendpoints
        @target_attachment = target_attachment
        @source = source
        @target = target
        @relationship = relationship
        @style = style
        @properties = properties
      end

      def replace(entity, with_entity)
        @relationship = with_entity.id if relationship == entity.id
        @source = with_entity.id if source == entity.id
        @target = with_entity.id if target == entity.id
      end

      def type_name
        Archimate::Color.color("#{Archimate::Color.data_model('Connection')}[#{Archimate::Color.color(@name || '', %i[white underline])}]", :on_light_magenta)
      end

      def element
        relationship
      end

      def to_s
        "#{type_name} #{source.nil? ? 'nothing' : source} -> #{target.nil? ? 'nothing' : target}"
      end

      def description
        [
          name.nil? ? nil : "#{name}: ",
          source&.description,
          relationship&.description,
          target&.description
        ].compact.join(" ")
      end

      def referenced_identified_nodes
        [@source, @target, @relationship].compact
      end

      # This is used when rendering a connection to connection relationship.
      def nodes
        []
      end

      # TODO: Is this true for all or only Archi models?
      def absolute_position
        # offset = bounds || Archimate::DataModel::Bounds.zero
        offset = Archimate::DataModel::Bounds.zero
        el = parent.parent
        while el.respond_to?(:bounds) && el.bounds
          bounds = el.bounds
          offset = offset.with(x: (offset.x || 0) + (bounds.x || 0), y: (offset.y || 0) + (bounds.y || 0))
          el = el.parent.parent
        end
        offset
      end
    end
  end
end
