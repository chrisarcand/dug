require 'test_helper'

class RunnerTest < MiniTest::Test
  def setup
    mock_label = mock('label')
    mock_label.stubs(:id).returns("unprocessed_label_id")

    @mock_servicer = mock('servicer')
    @mock_servicer.stubs(:authorize!)
    @mock_servicer.stubs(:labels).returns({ "GitHub/Unprocessed" => mock_label })

    @subject = Dug::GmailServicer.stub(:new, @mock_servicer) do
      Dug::Runner.new
    end
  end

  def test_processes_each_unprocessed_message
    mock_processor = mock('processor')

    response = mock('response')
    response.stubs(:messages).returns([stub(id: "1"), stub(id: "2"), stub(id: "3")])

    @mock_servicer.expects(:list_user_messages).with("me", label_ids: ["unprocessed_label_id"]).returns(response)
    Dug::MessageProcessor.expects(:new).times(3).returns(mock_processor)
    mock_processor.expects(:execute).times(3)

    @subject.run
  end
end
