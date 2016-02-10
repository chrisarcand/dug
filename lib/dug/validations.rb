module Dug
  module Validations
    def valid_rule_type?(type)
      LABEL_RULE_TYPES.include?(type.to_s)
    end

    def validate_rule_type!(type)
      unless valid_rule_type?(type)
        raise InvalidRuleType, "'#{type}' is not a valid label rule type. Valid types: #{LABEL_RULE_TYPES}"
      end
    end

    def valid_reason?(reason)
      GITHUB_REASONS.include?(reason.to_s)
    end

    def validate_reason!(reason)
      unless valid_reason?(reason)
        raise InvalidGitHubReason, "'#{reason}' is not a valid GitHub notification reason. Valid reasons include: #{GITHUB_REASONS.map { |x| "'#{x}'" }.join(', ')}"
      end
    end

    def valid_state?(state)
      ISSUE_STATES.include?(state.to_s)
    end

    def validate_state!(state)
      unless valid_state?(state)
        raise InvalidIssueState, "'#{state}' is not a valid issue state. Valid reasons include: #{ISSUE_STATES.map { |x| "'#{x}'" }.join(', ')}"
      end
    end
  end

  InvalidRuleType     = Class.new(StandardError)
  InvalidGitHubReason = Class.new(StandardError)
  InvalidIssueState   = Class.new(StandardError)
end

