require 'yaml'
require 'active_support/inflector'

module Dug
  class Configurator
    include Dug::Validations

    attr_accessor :client_id
    attr_accessor :client_secret
    attr_accessor :token_store
    attr_accessor :application_credentials_file
    attr_accessor :unprocessed_label_name

    def initialize
      self.label_rules = {}
      LABEL_RULE_TYPES.each do |type|
        label_rules[type] = {}
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

    def unprocessed_label_name
      @unprocessed_label_name || "GitHub/Unprocessed"
    end

    def rule_file
      @rule_file
    end

    def rule_file=(file_path)
      @rule_file = file_path
      load_rules
      @rule_file
    end

    def label_for(type, name, opts={})
      type = type.to_s
      validate_label_type!(type)
      validate_reason!(name) if type == 'reason'

      rule = label_rules[type.pluralize][name]
      case rule
      when String, nil
        rule
      when Array
        if type == 'repository'
          raise ArgumentError, "Multiple remotes possible and no remote specified" unless opts.keys.include?(:remote)
          rule = rule.detect do |r|
            r['remote'] == opts[:remote]
          end
          rule['label'] if rule
        end
      end
    end

    private

    attr_accessor :label_rules

    def load_rules
      # TODO should validate incoming YAML
      self.label_rules = YAML.load_file(rule_file)
    end
  end
end
