# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'archimate/version'

Gem::Specification.new do |spec|
  spec.name          = "archimate-model"
  spec.version       = Archimate::VERSION
  spec.authors       = ["Mark Morga"]
  spec.email         = ["markmorga@gmail.com"]

  spec.summary       = "ArchiMate Data Model"
  spec.description   = "ArchiMate Data Model Ruby Gem"
  spec.homepage      = "http://markmorga.com/archimate-model"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.require_paths = ["lib"]
  spec.metadata["yard.run"] = "yri" # use "yard" to build full HTML docs.
  spec.required_ruby_version = '>= 2.4.2'

  spec.add_runtime_dependency "ruby-enum", "~> 0.7.1"

  # Needed to run tests
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "faker"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-color"
  spec.add_development_dependency "minitest-matchers"
  spec.add_development_dependency "minitest-profile"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-json"

  # Other development helpers
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "pry-byebug"
end
