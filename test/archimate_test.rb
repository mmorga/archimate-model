require 'test_helper'

class ArchimateTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Archimate::VERSION
  end
end