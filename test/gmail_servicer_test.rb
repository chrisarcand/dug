require 'test_helper'

class GmailServicerTest < MiniTest::Test
  class GmailService
    ClientOptions = Struct.new(:application_name)
    ListLabelsResponse = Struct.new(:labels)
    Label = Struct.new(:id, :name)

    def list_user_labels(_user_id)
      ListLabelsResponse.new([
        Label.new("100", "Label 1"),
        Label.new("101", "Label 2"),
        Label.new("102", "Label 3")
      ])
    end

    def client_options
      @client_options ||= ClientOptions.new
    end
  end

  def setup
    @gmail = GmailService.new
    Google::Apis::GmailV1::GmailService.expects(:new).returns(@gmail)

    @subject = Dug::GmailServicer.new
  end

  def test_fetched_user_labels_keyed_by_name
    assert_instance_of GmailService::Label, @subject.labels["Label 2"]
    assert_equal "Label 2", @subject.labels["Label 2"].name
  end

  def test_add_labels_by_name
    request = mock("request")
    request.expects(:add_label_ids=).with(["100", "101"])

    message = mock("message")
    message.expects(:id).returns("message ID")

    Google::Apis::GmailV1::ModifyMessageRequest.stub(:new, request) do
      @gmail.expects(:modify_message).with("me", "message ID", request)
      @subject.add_labels_by_name(message, ["Label 1", "Label 2"])
    end
  end

  def test_remove_labels_by_name
    request = mock("request")
    request.expects(:remove_label_ids=).with(["100", "101"])

    message = mock("message")
    message.expects(:id).returns("message ID")

    Google::Apis::GmailV1::ModifyMessageRequest.stub(:new, request) do
      @gmail.expects(:modify_message).with("me", "message ID", request)
      @subject.remove_labels_by_name(message, ["Label 1", "Label 2"])
    end
  end

  def test_authorize
    skip
  end
end
