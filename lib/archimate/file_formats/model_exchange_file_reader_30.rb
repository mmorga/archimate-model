# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class ModelExchangeFileReader30 < ModelExchangeFileReader
      def parse_archimate_version(root)
        case root.namespace.href
        when "http://www.opengroup.org/xsd/archimate/3.0/"
          :archimate_3_0
        else
          raise "Unexpected namespace version: #{root.namespace.href}"
        end
      end

      def organizations_root_selector
        ">organizations"
      end

      def property_defs_selector
          ">propertyDefinitions>propertyDefinition"
      end

      def property_def_attr_name
        "propertyDefinitionRef"
      end

      def property_def_name(node)
        ModelExchangeFile::XmlLangString.parse(node.at_css("name"))
      end

      def parse_element_name(el)
        ModelExchangeFile::XmlLangString.parse(el.at_css(">name"))
      end

      def identifier_ref_name
        "identifierRef"
      end

      def diagrams_path
        ">views>diagrams>view"
      end

      def view_node_element_ref
        "elementRef"
      end

      def view_node_type_attr
        "xsi:type"
      end

      def connection_relationship_ref
        "relationshipRef"
      end

      def style_to_int(str)
        case str
        when nil
          0
        when "italic"
          1
        when "bold"
          2
        when "bold italic"
          3
        else
          raise "Broken for value: #{str}"
        end
      end
    end
  end
end