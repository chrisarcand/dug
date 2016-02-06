require 'test_helper'

class MessageProcessorTest < MiniTest::Test
  class MentionedMessage
    def id
      "123abc"
    end

    def headers
      { "Date" => "Some date", "From" => "Someone", "Subject" => "Some subject" }
    end

    def reason
      "mention"
    end

    def organization
      "chrisarcand"
    end

    def repository
      "dug"
    end
  end

  def setup
    @mock_servicer = MiniTest::Mock.new
  end

  def test_correct_mentioned_labels
    Dug.configure do |config|
      config.set_organization_rule("chrisarcand")
      config.set_repository_rule("dug", organization: "chrisarcand")
      config.set_reason_rule("mention")
    end

    @mock_message  = MentionedMessage.new

    Dug::NotificationDecorator.stub :new, @mock_message do
      @mock_servicer.expect(:get_user_message, nil, [String, String])
      @mock_servicer.expect(:add_labels_by_name, nil, [@mock_message, ["GitHub", "mention", "chrisarcand", "dug"]])
      @mock_servicer.expect(:remove_labels_by_name, nil, [@mock_message, ["GitHub/Unprocessed"]])

      Dug::MessageProcessor.new("dummy_id", @mock_servicer).execute
      @mock_servicer.verify
    end
  end
end