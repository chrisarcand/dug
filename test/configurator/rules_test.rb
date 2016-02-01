require 'test_helper'

class RulesTest < Minitest::Test
  def setup
    @config = Dug::Configurator.new
  end

  def test_set_org_without_label_returns_name
    @config.set_organization_rule('chrisarcand')
    label = @config.label_for(:organization, 'chrisarcand')
    assert_equal label, 'chrisarcand'
  end

  def test_set_org_with_label_returns_label
    @config.set_organization_rule('chrisarcand', label: 'Chris Arcand')
    label = @config.label_for(:organization, 'chrisarcand')
    assert_equal label, 'Chris Arcand'
  end

  def test_set_repo_without_label_returns_name
    @config.set_repository_rule('dotfiles', organization: 'chrisarcand')
    label = @config.label_for(:repository, 'dotfiles', organization: 'chrisarcand')
    assert_equal label, 'dotfiles'
  end

  def test_set_repo_with_label_returns_label
    @config.set_repository_rule('dotfiles', organization: 'chrisarcand', label: "Chris's dotfiles")
    label = @config.label_for(:repository, 'dotfiles', organization: 'chrisarcand')
    assert_equal label, "Chris's dotfiles"
  end

  def test_set_valid_reason_with_label_returns_label
    @config.set_reason_rule('mention', label: 'Hai, you were mentioned')
    label = @config.label_for(:reason, 'mention')
    assert_equal label, 'Hai, you were mentioned'
  end

  def test_set_valid_reason_without_label_returns_name
    @config.set_reason_rule('mention')
    label = @config.label_for(:reason, 'mention')
    assert_equal label, 'mention'
  end

  def test_set_invalid_reason_raises_error
    assert_raises(Dug::ConfigurationError) do
      @config.set_reason_rule('poked', label: 'lol')
    end
  end

  def test_label_for_invalid_type_raises_error
    assert_raises(Dug::ConfigurationError) do
      @config.label_for(:notification, 'chrisarcand')
    end
  end
end
