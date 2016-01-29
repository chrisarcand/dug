require "dug/version"
require "dug/configurator"
require "dug/logger"
require "dug/gmail_servicer"
require "dug/github_notification_labeller"

module Dug
  def self.configure(&block)
    yield configuration
  end

  def self.configuration
    @config ||= Dug::Configurator.new
  end
end
