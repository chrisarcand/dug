require 'yaml'

module Dug
  class Configurator
    LABEL_RULE_TYPES = %i(organization repository reason)
    GITHUB_REASONS = %w(author comment mention team_mention state_change assign)

    attr_accessor :client_id
    attr_accessor :client_secret
    attr_accessor :application_credentials_file
    attr_accessor :rule_file

    def initialize
      self.label_rules = { "subscriptions" => {}, "reasons" => {} }
      load_rule_file if ENV['RULES_PATH'] || rule_file
    end

    def set_organization_rule(name, label: nil)
      subscriptions[name] ||= { "repositories" => {} }
      subscriptions[name]["label"] = label || name
    end

    def set_repository_rule(name, organization:, label: nil)
      subscriptions[organization] ||= { "repositories" => {} }
      subscriptions[organization]["repositories"][name] ||= {}
      subscriptions[organization]["repositories"][name]["label"] = label || name
    end

    def set_reason_rule(name, label: nil)
      validate_reason(name)
      reasons[name] ||= {}
      reasons[name]["label"] = label || name
    end

    def label_for(type, name:, organization: nil)
      validate_label_type(type)
      case type
      when :organization
        subscriptions.fetch(name, {})["label"]
      when :repository
        raise ArgumentError, "Repository label rules require an organization to be specified" unless organization
        subscriptions.fetch(organization, {})
                     .fetch("repositories", {})
                     .fetch(name, {})["label"]
      when :reason
        validate_reason(name)
        reasons.fetch(name, {})["label"]
      end
    end

    def client_id
      ENV['GOOGLE_APPLICATION_CREDENTIALS'] || @application_credentials_file
    end

    def client_id
      ENV['GOOGLE_CLIENT_ID'] || @client_id
    end

    def client_id
      ENV['GOOGLE_CLIENT_SECRET'] || @client_secret
    end

    private

    attr_accessor :label_rules

    def load_config
      config = YAML.load_file(config_path)
      require 'pry'
      binding.pry
    end

    def validate_label_type(type)
      unless LABEL_RULE_TYPES.include?(type)
        raise ConfigurationError, "'#{type}' is not a valid label rule type. Valid types: #{}"
      end
    end

    def validate_reason(reason)
      unless GITHUB_REASONS.include?(reason)
        raise ConfigurationError, "'#{reason}' is not a valid GitHub notification reason. Valid reasons include: #{GITHUB_REASONS.map { |x| "'#{x}'" }.join(', ')}"
      end
    end

    def subscriptions
      label_rules["subscriptions"]
    end

    def reasons
      label_rules["reasons"]
    end
  end

  ConfigurationError = Class.new(StandardError)
end
