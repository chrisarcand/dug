require 'test_helper'

class DugTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Dug::VERSION
  end
end
