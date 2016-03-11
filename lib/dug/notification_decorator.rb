module Dug
  class NotificationDecorator < SimpleDelegator
    %w(Date From To Subject).each do |header|
      define_method(header.downcase) do
        headers[header]
      end
    end

    def organization
      list_match(1)
    end

    def repository
      list_match(2)
    end

    def reason
      headers["X-GitHub-Reason"]
    end

    def headers
      @headers ||= payload.headers.each_with_object({}) do |header, hash|
        hash[header.name] = header.value
      end
    end

    def indicates_merged?
      !!(plaintext_body =~ /^Merged #(?:\d+)\./)
    end

    def indicates_closed?
      # Note: Purposely more lax than Merged
      # Issues can be closed via PR/commit ie "Closed #123 via #456."
      !!(plaintext_body =~ /^Closed #(?:\d+)/)
    end

    def indicates_reopened?
      !!(plaintext_body =~ /^Reopened #(?:\d+)\./)
    end

    private

    def list_match(index)
      headers["List-ID"] && headers["List-ID"].match(/^([\w\-_]+)\/([\w\-_]+)/)[index]
    end

    def plaintext_body
      @plaintext_body ||= \
        begin
          parts = payload.parts || Array(payload)
          parts.detect { |part| part.mime_type == 'text/plain' }.body.data
        end
    end
  end
end
