module Dug
  module Validations
    def valid_label_type?(type)
      LABEL_RULE_TYPES.include?(type)
    end

    def validate_label_type!(type)
      unless valid_label_type?(type)
        raise InvalidRuleType, "'#{type}' is not a valid label rule type. Valid types: #{LABEL_RULE_TYPES}"
      end
    end

    def valid_reason?(reason)
      GITHUB_REASONS.include?(reason)
    end

    def validate_reason!(reason)
      unless valid_reason?(reason)
        raise InvalidGitHubReason, "'#{reason}' is not a valid GitHub notification reason. Valid reasons include: #{GITHUB_REASONS.map { |x| "'#{x}'" }.join(', ')}"
      end
    end
  end

  InvalidRuleType = Class.new(StandardError)
  InvalidGitHubReason = Class.new(StandardError)
end

