require "dug/version"
require "dug/configurator"
require "dug/logger"
require "dug/gmail_servicer"
require "dug/github_notification_labeller"

module Dug
  def self.configure(&block)
    yield _config
  end

  def self._config
    @config ||= Dug::Configurator.new
  end
end
