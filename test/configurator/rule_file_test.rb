require 'test_helper'

class RuleFileTest < Minitest::Test
  def setup
    @valid_config = Dug.configure do |config|
      config.rule_file = File.expand_path("../rule_file_fixtures/valid_rule_file.yml", __FILE__)
    end
  end

  def test_it_configures_all_values_as_expected
    assert_equal Dug.configuration.label_for(:organization, 'rails'), 'Rails'
    assert_equal Dug.configuration.label_for(:organization, 'rspec'), 'RSpec'
    assert_equal Dug.configuration.label_for(:organization, 'ManageIQ'), 'ManageIQ'

    assert_equal Dug.configuration.label_for(:repository, 'rspec-expectations'), 'RSpec/rspec-expectations'
    assert_equal Dug.configuration.label_for(:repository, 'more_core_extensions'), nil

    assert_equal Dug.configuration.label_for(:reason, 'author'), 'Participating'
    assert_equal Dug.configuration.label_for(:reason, 'comment'), 'Participating'
    assert_equal Dug.configuration.label_for(:reason, 'mention'), 'Mentioned'
    assert_equal Dug.configuration.label_for(:reason, 'team_mention'), 'Team mention'
    assert_equal Dug.configuration.label_for(:reason, 'assign'), 'Assigned to me'
  end

end
