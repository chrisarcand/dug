require "dug/version"
require "dug/validations"
require "dug/configurator"
require "dug/gmail_servicer"
require "dug/logger"
require "dug/message_processor"
require "dug/notification_decorator"
require "dug/runner"
require "dug/util"

module Dug
  LABEL_RULE_TYPES = %w(organization repository reason state)
  GITHUB_REASONS = %w(author comment mention team_mention state_change assign manual subscribed)
  ISSUE_STATES = %(merged closed reopened)

  def self.authorize!
    Dug::GmailServicer.new.authorize!
  end

  def self.configure(&block)
    yield configuration
  end

  def self.configuration
    @config ||= Dug::Configurator.new
  end
end
