# frozen_string_literal: true

module Archimate
  # Support Archimate file format versions
  SUPPORTED_FORMATS = %i[
    archi_3
    archi_4
    archimate_2_1
    archimate_3_0
  ].freeze

  # Archimate modeling specification version
  ARCHIMATE_VERSIONS = %i[
    archimate_2_1
    archimate_3_0
  ].freeze

  autoload :DerivedRelations, 'archimate/derived_relations'

  require "archimate/version"
  require "archimate/core_refinements"
  require "archimate/logging"
  require "archimate/color"
  require "archimate/data_model"
end
