# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# TODO: This is for MRI only
if ENV['TEST_ENV'] != 'guard'
  require 'simplecov'
  require 'simplecov-json'
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::JSONFormatter
    ]
  )
  SimpleCov.start do
    track_files "*.rb"
    add_filter "/test/"
  end
  puts "required simplecov"
end

require 'minitest/autorun'
require 'minitest/color'
require 'minitest/profile'
require 'faker'
require 'pp'
require 'archimate'
require_relative 'examples/factories'

Minitest::Test.make_my_diffs_pretty!

module Minitest
  class Test
    include Archimate::Examples::Factories

    def clone_with(entity, attrs = {})
      entity.class.new(entity.to_hash.merge(attrs).transform_values(&:dup))
    end
  end
end
