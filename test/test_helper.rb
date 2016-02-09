$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

$testing = true

# Because Code Climate stupidly doesn't defer to SimpleCov and
# run if it's not actually posting to CC (not by design), so you
# can't just add another formatter to SimpleCov as they claim.
if ENV['CI']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
    add_filter '/lib/dug/version.rb'
  end
end

require 'dug'
require 'minitest/autorun'
require "minitest/reporters"
require 'mocha/mini_test'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

Minitest::Unit.after_tests { Dug.configuration._clear! }
