require 'test_helper'

class UtilTest < MiniTest::Test
  include Dug::Util

  def test_pluralization
    assert_equal Dug::Util.pluralize("organization"), "organizations"
    assert_equal Dug::Util.pluralize("repository"), "repositories"
    assert_equal Dug::Util.pluralize("reason"), "reasons"
    assert_equal Dug::Util.pluralize("state"), "states"
  end
end
