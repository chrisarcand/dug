require 'test_helper'

class DugTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Dug::VERSION
  end

  def test_authorize_bang_inits_and_authorizes_gmail_servicer
    servicer = MiniTest::Mock.new
    servicer.expect(:authorize!, nil)
    Dug::GmailServicer.stub :new, servicer do
      Dug.authorize!
    end

    assert servicer.verify
  end
end
