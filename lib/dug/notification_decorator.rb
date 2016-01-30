module Dug
  class NotificationDecorator < SimpleDelegator
    %w(Date From To Subject).each do |header|
      define_method(header.downcase) do
        headers[header]
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

    def headers
      @headers ||= payload.headers.each_with_object({}) do |header, hash|
        hash[header.name] = header.value
      end
    end

    private

    def list_match
      headers["List-ID"].match(/^([\w\-_]+)\/([\w\-_]+)/)
    end
  end
end
