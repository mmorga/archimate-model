# frozen_string_literal: true

require 'test_helper'

module Archimate
  class DerivedRelationsTest < Minitest::Test
    DerivedRelationCase = Struct.new(:type, :source, :target)

    def setup
      @a = build_element(type: "ApplicationComponent", name: "A", id: "a")
      @b = build_element(type: "ApplicationComponent", name: "B", id: "b")
      @app_func = build_element(type: "ApplicationFunction", name: "Application Function", id: "app_func")
      @c = build_element(type: "ApplicationComponent", name: "C", id: "c")
      @d = build_element(type: "ApplicationComponent", name: "D", id: "d")
      @d_api = build_element(type: "ApplicationInterface", name: "D API", id: "d_api")
      @d_svc = build_element(type: "ApplicationService", name: "D Service", id: "d_svc")
      @d_func = build_element(type: "ApplicationFunction", name: "D Function", id: "d_fun")

      @a_to_b = build_relationship(type: "ServingRelationship", source: @a, target: @b)
      @a_to_app_func = build_relationship(type: "AssignmentRelationship", source: @a, target: @app_func)
      @d_to_d_api = build_relationship(type: "CompositionRelationship", source: @d, target: @d_api)
      @d_api_to_d_svc = build_relationship(type: "AssignmentRelationship", source: @d_api, target: @d_svc)
      @d_func_to_d_svc = build_relationship(type: "RealizationRelationship", source: @d_func, target: @d_svc)
      @d_svc_to_app_func = build_relationship(type: "ServingRelationship", source: @d_svc, target: @app_func)
      @c_to_app_func = build_relationship(type: "ServingRelationship", source: @c, target: @app_func)
      @d_to_d_func = build_relationship(type: "AssignmentRelationship", source: @d, target: @d_func)
      @d_api_to_a = build_relationship(type: "ServingRelationship", source: @d_api, target: @a)

      @model = build_model(
        elements: [@a, @b, @app_func, @c, @d, @d_api, @d_svc],
        relationships: [
          @a_to_b, @a_to_app_func, @d_to_d_api, @d_api_to_d_svc, @d_func_to_d_svc,
          @d_svc_to_app_func, @c_to_app_func, @d_to_d_func, @d_api_to_a
        ]
      )

      @subject = DerivedRelations.new(@model)
    end

    def test_element_by_name
      @model.elements.each do |el|
        assert_equal @model.elements.find(&DataModel.by_name(el.name)), el
      end
    end

    def test_traverse_for_simple_case_a
      app_comp_a = @model.elements.find(&DataModel.by_name("A"))
      expected = app_comp_a.source_relationships.map { |rel| [rel] }

      actual = @subject.traverse(
        [app_comp_a],
        ->(_rel) { true },
        ->(_el) { true }
      )

      assert_equal to_id_array(expected), to_id_array(actual)
    end

    def test_traverse_for_complex_case_d
      expected = [
        @d_to_d_api,
        @d_to_d_func,
        [@d_to_d_api, @d_api_to_d_svc],
        [@d_to_d_api, @d_api_to_a],
        [@d_to_d_api, @d_api_to_d_svc, @d_svc_to_app_func],
        [@d_to_d_api, @d_api_to_a, @a_to_b],
        [@d_to_d_api, @d_api_to_a, @a_to_app_func],
        [@d_to_d_func, @d_func_to_d_svc],
        [@d_to_d_func, @d_func_to_d_svc, @d_svc_to_app_func]
      ]

      actual = @subject.traverse(
        [@d],
        DerivedRelations::PASS_ALL,
        DerivedRelations::FAIL_ALL
      )

      assert_equal 9, actual.size
      expected.each { |path| assert_includes actual, path }
      assert_equal to_id_array(expected), to_id_array(actual)
    end

    def test_has_derived_relationships
      expected = [
        DerivedRelationCase.new('Assignment', @d.id, @d_svc.id),
        DerivedRelationCase.new('Serving', @d.id, @app_func.id),
        DerivedRelationCase.new('Realization', @d.id, @d_svc.id),
        DerivedRelationCase.new('Serving', @d.id, @a.id),
        DerivedRelationCase.new('Serving', @d.id, @b.id)
      ]

      actual = @subject.derived_relations(
        [@d],
        DerivedRelations::PASS_ALL,
        DerivedRelations::PASS_ALL,
        DerivedRelations::FAIL_ALL
      )

      assert_equal 5, actual.size
      actual.each do |rel|
        assert_kind_of DataModel::Relationship, rel
        assert rel.derived
        assert_includes expected, DerivedRelationCase.new(rel.type, rel.source.id, rel.target.id)
      end
    end

    def test_has_derived_serving_relationships_to_app_components
      expected = [
        DerivedRelationCase.new('Serving', @d.id, @a.id),
        DerivedRelationCase.new('Serving', @d.id, @b.id)
      ]

      actual = @subject.derived_relations(
        [@d],
        ->(rel) { rel.weight >= DataModel::Relationships::Serving::WEIGHT },
        ->(el) { el.type == "ApplicationComponent" }
      )

      assert_equal 2, actual.size
      actual.each do |rel|
        assert_kind_of DataModel::Relationship, rel
        assert rel.derived
        assert_includes expected, DerivedRelationCase.new(rel.type, rel.source.id, rel.target.id)
      end
    end

    private

    def to_id_array(items)
      items
        .map { |item| Array(item).map { |rel| "#{rel.source.name}->#{rel.target.name}" }.join(", ") }
    end

    def short_rel_desc(rel)
      "#{rel.source.type}: #{rel.source.name} -> #{rel.target.type}: #{rel.target.name}"
    end

    def to_textual_array(items)
      items
        .map do |item|
          rels = Array(item)
          <<~MESSAGE
            Derived Relation #{rels.first.source.type}: #{rels.first.source.name} -> #{rels.last.target.type}: #{rels.last.target.name}
                #{rels.map { |rel| short_rel_desc(rel) }.join("\n    ")}
          MESSAGE
        end
    end
  end
end
