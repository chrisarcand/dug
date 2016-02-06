require 'test_helper'

class NotificationDecoratorTest < MiniTest::Test
  GmailPayload = Struct.new(:headers)
  GmailHeader = Struct.new(:name, :value)

  class GmailMessage
    def payload
      headers = [
        GmailHeader.new("Date", "Sat, 06 Feb 2016 05:32:21 -0800"),
        GmailHeader.new("From", "\"Not Chris Arcand (Test bot)\" <notifications@github.com>"),
        GmailHeader.new("To", "chrisarcand/dug <dug@noreply.github.com>"),
        GmailHeader.new("Subject", "Re: [dug] MessageProcessor Extraction (#2)"),
        GmailHeader.new("X-GitHub-Reason", "author"),
        GmailHeader.new("List-ID", "chrisarcand/dug <dug.chrisarcand.github.com>")
      ]
      GmailPayload.new(headers)
    end
  end

  def setup
    @subject = Dug::NotificationDecorator.new(GmailMessage.new)

    @expected_headers = {
      "Date" => "Sat, 06 Feb 2016 05:32:21 -0800",
      "From" => "\"Not Chris Arcand (Test bot)\" <notifications@github.com>",
      "To" => "chrisarcand/dug <dug@noreply.github.com>",
      "Subject" => "Re: [dug] MessageProcessor Extraction (#2)",
      "X-GitHub-Reason" => "author",
      "List-ID" => "chrisarcand/dug <dug.chrisarcand.github.com>"
    }
  end

  def test_organization
    assert_equal @subject.organization, "chrisarcand"
  end

  def test_repository
    assert_equal @subject.repository, "dug"
  end

  def test_reason
    assert_equal @subject.reason, "author"
  end

  def test_headers
    assert_equal @subject.headers, @expected_headers
  end

  def test_misc_header_methods
    assert_equal @subject.date, @expected_headers["Date"]
  end
end
