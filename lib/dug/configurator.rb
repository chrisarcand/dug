module Dug
  class Configurator
    LABEL_RULE_TYPES = %i(organization repository reason)
    GITHUB_REASONS = %i(author comment mention team_mention state_change assign)

    attr_reader :label_rules

    def initialize
      @label_rules = { 'subscriptions' => {}, 'reasons' => {} }
    end

    def set_label_rule(type, name:, organization: nil, labels:)
      labels = Array(labels)
      unless LABEL_RULE_TYPES.include?(type)
        raise ConfigurationError, "'#{type}' is not a valid label rule type. Valid types: #{}"
      end

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
        unless GITHUB_REASONS.include?(reason)
          raise ConfigurationError, "'#{reason.to_s}' is not a valid GitHub notification reason. Valid reasons include: #{Dug::VALID_GITHUB_REASONS.map { |x| ":#{x}" }.join(', ')}"
        end
        reasons[name] = { labels: labels }
      end
      nil
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
