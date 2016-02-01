require 'yaml'

module Dug
  class Configurator
    LABEL_RULE_TYPES = %i(organization repository reason)
    GITHUB_REASONS = %w(author comment mention team_mention state_change assign)

    attr_accessor :client_id
    attr_accessor :client_secret
    attr_accessor :token_store
    attr_accessor :application_credentials_file

    def initialize
      self.label_rules = { "subscriptions" => {}, "reasons" => {} }
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

    def application_credentials_file
      ENV['GOOGLE_APPLICATION_CREDENTIALS'] || @application_credentials_file
    end

    def client_id
      ENV['GOOGLE_CLIENT_ID'] || @client_id
    end

    def client_secret
      ENV['GOOGLE_CLIENT_SECRET'] || @client_secret
    end

    def token_store
      ENV['TOKEN_STORE_PATH'] || @token_store || File.join(Dir.home, ".dug", "authorization.yaml")
    end

    def rule_file
      @rule_file
    end

    def rule_file=(file_path)
      @rule_file = file_path
      load_rules
      @rule_file
    end

    private

    attr_accessor :label_rules

    def load_rules
      file = YAML.load_file(rule_file)

      file["subscriptions"].each do |org|
        case org
        when String
          set_organization_rule(org)
        when Hash
          org_name = org.keys.first
          org_options = org[org_name]

          set_organization_rule(org_name, label: org_options["label"])
          if org_options["repositories"]
            org_options["repositories"].each do |repo|
              case repo
              when String
                set_repository_rule(repo, organization: org_name)
              when Hash
                repo_name = repo.keys.first
                repo_options = repo[repo_name]
                set_repository_rule(repo_name, organization: org_name, label: repo_options["label"])
              end
            end
          end
        end
      end

      file["reasons"].keys.each do |reason|
        validate_reason(reason)
        set_reason_rule(reason, label: file["reasons"][reason]["label"])
      end
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
