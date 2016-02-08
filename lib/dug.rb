require "dug/version"
require "dug/validations"
require "dug/configurator"
require "dug/gmail_servicer"
require "dug/logger"
require "dug/message_processor"
require "dug/notification_decorator"
require "dug/runner"

module Dug
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
