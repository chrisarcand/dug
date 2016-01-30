module Dug
  class NotificationDecorator < SimpleDelegator
    def headers
      @headers ||= payload.headers.each_with_object({}) do |header, hash|
        hash[header.name] = header.value
      end
    end

    def organization
      list_match[1]
    end

    def repository
      list_match[2]
    end

    def reason
      headers["X-GitHub-Reason"]
    end

    private

    def list_match
      headers["List-ID"].match(/^([\w\-_]+)\/([\w\-_]+)/)
    end
  end
end
