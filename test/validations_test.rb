require 'test_helper'

class ValidationsTest < MiniTest::Test
  include Dug::Validations

  def test_valid_rule_type_query
    assert_equal valid_rule_type?(:wrong), false
    assert_equal valid_rule_type?(:repositories), false
    assert_equal valid_rule_type?(:repository), true
    assert_equal valid_rule_type?(:organization), true
  end

  def test_validate_rule_type
    assert_raises(Dug::InvalidRuleType) { validate_rule_type!(:wrong) }
    assert_raises(Dug::InvalidRuleType) { validate_rule_type!(:repositories) }

    # No raises
    validate_rule_type!(:repository)
    validate_rule_type!(:organization)
  end

  def test_valid_reason_query
    assert_equal valid_reason?(:wrong), false
    assert_equal valid_reason?(:troller), false
    assert_equal valid_reason?(:mention), true
    assert_equal valid_reason?(:author), true
  end

  def test_validate_reason
    assert_raises(Dug::InvalidGitHubReason) { validate_reason!(:wrong) }
    assert_raises(Dug::InvalidGitHubReason) { validate_reason!(:troller) }

    # No raises
    validate_reason!(:mention)
    validate_reason!(:author)
  end
end
