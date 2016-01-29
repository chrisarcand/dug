module Dug
  class Configurator
    LABEL_RULE_TYPES = %i(organization repository reason)
    GITHUB_REASONS = %w(author comment mention team_mention state_change assign)

    attr_reader :label_rules

    def initialize
      @label_rules = { 'subscriptions' => {}, 'reasons' => {} }
    end

    def set_label_rule(type, name:, organization: nil, labels:)
      labels = Array(labels)
      validate_label_type(type)

      case type
      when :organization
        subscriptions[name] ||= {}
        subscriptions[name]['labels'] = labels
      when :repository
        raise ArgumentError, "Repository label rules require an organization to be specified" unless organization
        subscriptions[organization] ||= {}
        subscriptions[organization]['repositories'] ||= {}
        subscriptions[organization]['repositories'][name] = { 'labels' => labels }
      when :reason
        validate_reason(name)
        reasons[name] = { labels: labels }
      end
      nil
    end

    def labels_for(type, name:, organization: nil)
      validate_label_type(type)
      case type
      when :organization
        subscriptions.fetch(name, {})['labels']
      when :repository
        raise ArgumentError, "Repository label rules require an organization to be specified" unless organization
        subscriptions.fetch(organization, {})
                     .fetch('repositories', {})
                     .fetch(name, {})['labels']
      when :reason
        validate_reason(name)
        reasons.fetch(name, {})['labels']
      end
    end

    private

    def validate_label_type(type)
      unless LABEL_RULE_TYPES.include?(type)
        raise ConfigurationError, "'#{type}' is not a valid label rule type. Valid types: #{}"
      end
    end

    def validate_reason(reason)
      unless GITHUB_REASONS.include?(reason)
        raise ConfigurationError, "'#{reason}' is not a valid GitHub notification reason. Valid reasons include: #{Dug::VALID_GITHUB_REASONS.map { |x| "'#{x}'" }.join(', ')}"
      end
    end

    def subscriptions
      label_rules['subscriptions']
    end

    def reasons
      label_rules['reasons']
    end
  end

  ConfigurationError = Class.new(StandardError)
end
