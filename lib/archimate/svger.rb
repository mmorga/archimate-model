require "nokogiri"
require 'RMagick'

module Archimate
  class Svger
    XSI = "http://www.w3.org/2001/XMLSchema-instance"

    def text_width(text)
      draw = Magick::Draw.new
      draw.font = "/System/Library/Fonts/LucidaGrande.ttc"
      draw.pointsize = 12
      draw.get_type_metrics(text).width
    end

    def fit_text_to_width(text, width)
      # t = Text.new
      results = []
      words = text.split(" ")
      candidate = words.shift
      until words.empty? do
        next_word = words.shift
        new_candidate = candidate + " " + next_word
        # if t.width(new_candidate) > width
        if text_width(new_candidate) > width
          results << candidate
          candidate = next_word
        else
          candidate = new_candidate
        end
      end
      results << candidate
      results
    end

    def element_type(el)
      el.attribute_with_ns("type", XSI).value[10..-1]
    end

    $todos = Hash.new(0)

    BADGES = {
      "ApplicationInterface" => "#interface-badge",
      "ApplicationInteraction" => "#interaction-badge",
      "ApplicationCollaboration" => "#collaboration-badge",
      "ApplicationFunction" => "#function-badge",
      "BusinessActor" => "#actor-badge"
    }

    def draw_element_rect(xml, element, ctx)
      x = ctx["x"].to_i + ctx["width"].to_i - 25
      y = ctx["y"].to_i + 5
      el_type = element_type(element)
      case el_type
      when "ApplicationService", "BusinessService", "InfrastructureService"
        xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"], rx: "27.5", ry: "27.5")
      when "ApplicationInterface", "BusinessInterface"
        xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
        xml.use(x: "0", y: "0", width: "20", height: "15", transform: "translate(#{x}, #{y})", "xlink:href" => "#interface-badge")
      when "BusinessActor"
        xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
        xml.use(x: "0", y: "0", width: "20", height: "15", transform: "translate(#{x}, #{y})", "xlink:href" => "#actor-badge")
      when "ApplicationInteraction"
        xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"], rx: "10", ry: "10")
        xml.use(x: "0", y: "0", width: "20", height: "15", transform: "translate(#{x}, #{y})", "xlink:href" => "#interaction-badge")
      when "ApplicationCollaboration", "BusinessCollaboration"
        xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
        xml.use(x: "0", y: "0", width: "20", height: "15", transform: "translate(#{x}, #{y})", "xlink:href" => "#collaboration-badge")
      when "ApplicationFunction", "BusinessFunction", "InfrastructureFunction"
        xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"], rx: "10", ry: "10")
        xml.use(x: "0", y: "0", width: "20", height: "15", transform: "translate(#{x}, #{y})", "xlink:href" => "#function-badge")
      when "ApplicationComponent"
        xml.rect(x: ctx["x"].to_i + 10, y: ctx["y"], width: ctx["width"].to_i - 10, height: ctx["height"])
        xml.use(x: "0", y: "0", width: "23", height: "44", class: "topbox", transform: "translate(#{ctx["x"]}, #{ctx["y"]})", "xlink:href" => "#component-knobs")
      when "DataObject"
        xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
        xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: "14", class: "topbox")
      else
        # puts "TODO: implement #{el_type}"
        $todos[el_type] += 1
        xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
      end
    end

    def element_text_bounds(element, ctx)
      case element_type(element)
      when "ApplicationService"
        {
          x: ctx["x"].to_i + 10, y: ctx["y"].to_i, width: ctx["width"].to_i - 20, height: ctx["height"]
        }
      when "DataObject"
        {
          x: ctx["x"].to_i + 5, y: ctx["y"].to_i + 14, width: ctx["width"].to_i - 10, height: ctx["height"]
        }
      else
        {
          x: ctx["x"].to_i + 5, y: ctx["y"].to_i, width: ctx["width"].to_i - 30, height: ctx["height"]
        }
      end
    end

    def draw_element(xml, obj, context = nil)
      bounds = obj.at_css(">bounds")
      element_id = obj.attr("archimateElement") || obj.attr("id")
      element = obj.document.at_css("##{element_id}")
      group_attrs = {id: element_id, class: element_type(element)}
      group_attrs[:transform] = "translate(#{context["x"]}, #{context["y"]})" unless context.nil?
      xml.g(group_attrs) {
        draw_element_rect(xml, element, bounds)
        tctx = element_text_bounds(element, bounds)
        y = tctx[:y].to_i
        x = bounds[:x].to_i + (bounds[:width].to_i / 2)
        content = element.attr("name") || element.at_css("content").text
        fit_text_to_width(content, tctx[:width].to_i).each { |line|
          y += 17
          xml.text_(x: x, y: y, "text-anchor" => :middle) {
            xml.text line
          }
        }
        obj.css(">child").each {|child| draw_element(xml, child, bounds)}
      }
    end

    svg_str =<<EOS
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1"
     xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink">

    <style type="text/css" >
      <![CDATA[

        text {
          font-size: 12px;
          font-family: "Lucida Grande";
          fill: black;
          stroke: none;
        }
        # rect {
        #    stroke: #000000;
        #    fill:   #eeeeee;
        # }
        .BusinessActor rect,
        .BusinessRole,
        .BusinessCollaboration,
        .BusinessInterface,
        .Location,
        .BusinessProcess,
        .BusinessFunction,
        .BusinessInteraction,
        .BusinessEvent,
        .BusinessService,
        .BusinessObject,
        .Representation,
        .Meaning,
        .Value,
        .Product,
        .Contract {
          fill: rgb(255, 255, 181);
          stroke: rgb(178, 178, 126);
        }
        .ApplicationCollaboration rect,
        .ApplicationComponent rect,
        .ApplicationFunction rect,
        .ApplicationInteraction rect,
        .ApplicationInterface rect,
        .ApplicationService rect,
        .DataObject rect {
          fill: rgb(181, 255, 255);
          stroke: rgb(126, 178, 178);
        }
        .Plateau {
          fill: rgb(224,255,224);
          stroke: rgb(170,194,170);
        }
        .DataObject rect.topbox,
        .ApplicationComponent rect.topbox,
        .topbox {
          fill: rgb(162, 229, 229);
        }
        .Node,
        .Device,
        .SystemSoftware,
        .InfrastructureInterface,
        .Network,
        .CommunicationPath,
        .InfrastructureFunction,
        .InfrastructureService,
        .Artifact {
          fill: #cae6b9;
          stroke: #8ca081;
        }
        .technology-box-shade {
          fill: #b5cea6;
          stroke: #8ca081;
        }
        .technology-group {
          fill: #e1fee1;
          stroke: #9db29d;
        }
        .technology-group-shade {
          fill: #cae4ca;
          stroke: #9db29d;
        }
      ]]>
    </style>
    <defs>
      <symbol id="interface-badge" viewBox="0 0 20 15" preserveAspectRatio="xMaxYMin meet">
        <circle fill="none" r="5" cx="14" cy="6" stroke="black"/>
        <line fill="none" x1="0" x2="9" y1="5" y2="5" stroke="black"/>
      </symbol>
      <symbol id="interaction-badge" viewBox="0 0 20 15" preserveAspectRatio="xMaxYMin meet">
        <path fill="none" d="M11 1 C8.2386 1 6 3.6863 6 7 C6 10.3137 8.2386 13 11 13 L11 0.5" fill-rule="evenodd" stroke="black"/>
        <path fill="none" d="M14 13 C17.7614 13 19 10.3137 19 7 C19 3.6863 16.7614 1 14 1 L14 13.5" fill-rule="evenodd" stroke="black"/>
      </symbol>
      <symbol id="collaboration-badge" viewBox="0 0 20 15" preserveAspectRatio="xMaxYMin meet">
        <circle fill="none" r="5" cx="10" cy="6" stroke="black"/>
        <circle fill="none" r="5" cx="14" cy="6" stroke="black"/>
      </symbol>
      <symbol id="function-badge" viewBox="342 105 20 15" preserveAspectRatio="xMaxYMin meet">
        <polygon fill="none" points=" 350 120 350 111 356 106 362 111 362 120 356 114" stroke="black"/>
      </symbol>
      <symbol id="component-knobs" viewbox="0 0 23 44" preserveAspectRatio="xMaxYMin meet">
        <rect x="1" y="10" width="21" height="13" class="topbox"/>
        <rect x="1" y="30" width="21" height="13" class="topbox"/>
      </symbol>
      <symbol id="actor-badge" viewbox="0 0 20 15" preserveAspectRatio="xMaxYMin meet">
        <circle fill="none" r="3" cx="15" cy="4" stroke="black"/>
        <line fill="none" x1="15" x2="15" y1="6" y2="12" stroke="black"/>
        <line fill="none" x1="15" x2="11" y1="12" y2="17" stroke="black"/>
        <line fill="none" x1="15" x2="19" y1="12" y2="17" stroke="black"/>
        <line fill="none" x1="11" x2="19" y1="8" y2="8" stroke="black"/>
      </symbol>
      <symbol id="role-badge" viewbox="0 0 20 15" preserveAspectRatio="xMaxYMin meet">
        <path fill="none" d="M278 18 C275.7909 18 274 19.567 274 21.5 C274 23.433 275.7909 25 278 25 L285 25 M277.5 18 L285 18" stroke="black"/>
        <circle fill="none" r="3.5" cx="16.5" cy="4" stroke="black"/>
      </symbol>
    </defs>
</svg>
EOS

    def make_svgs(archi_file)
      doc = Nokogiri::XML(File.open(archi_file))

      doc.css('element[xsi|type="archimate:ArchimateDiagramModel"]').each do |diagram|
        svg_doc = Nokogiri::XML::Document.parse(svg_str)
        svg = svg_doc.at_css("svg")
        name = diagram.attr("name")
        puts name
        diagram.css(">child").each do |child|
          builder = Nokogiri::XML::Builder.with(svg) do |xml|
            draw_element(xml, child)
          end
        end

        File.open("generated/#{name}.svg", "wb") do |f|
          f.write(svg_doc.to_xml)
        end
      end

      puts "\n\n"
      $todos.keys.sort.each { |el| puts "#{el}: #{$todos[el]}" }
    end
  end
end
