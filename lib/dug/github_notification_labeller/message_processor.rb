module Dug
  module GithubNotificationLabeller
    class MessageProcessor
      include Dug::Logger

      def self.process_message!(*args)
        new(*args).process_message!
      end

      def initialize(servicer, message)
        @servicer = servicer
        @message = message
      end

      def process_message!
        info = "Processing message:"
        info << "\n    ID: #{@message.id}"
        %w(Date From Subject).each do |header|
          info << "\n    #{header}: #{headers[header]}"
        end
        info << "\n    * Applying labels: #{labels_to_add.join(' | ')} *"
        log(info)

        add_labels_by_name(labels_to_add)
        remove_labels_by_name(labels_to_remove)
      end

      def labels_to_add
        ["GitHub"] + project_labels + reason_labels
      end

      def labels_to_remove
        ["GitHub/Unprocessed"]
      end

      private

      def add_labels_by_name(label_names)
        ids = label_names.map { |name| @servicer.labels[name].id }

        request = Google::Apis::GmailV1::ModifyMessageRequest.new
        request.add_label_ids = ids
        @servicer.modify_message('me', @message.id, request)
      end

      def remove_labels_by_name(label_names)
        ids = label_names.map { |name| @servicer.labels[name].id }

        request = Google::Apis::GmailV1::ModifyMessageRequest.new
        request.remove_label_ids = ids
        @servicer.modify_message('me', @message.id, request)
      end

      def reason_labels
        labels = []
        if %w(author comment).include?(reason)
          labels << "Participating"
        end
        if reason == "mention"
          labels << "Mentioned by name"
        end
        if reason == "team_mention"
          labels << "Team mention"
        end
        if reason == "assign"
          labels << "Assigned"
        end
        labels
      end

      def project_labels
        labels = []
        if organization == "ManageIQ"
          labels << "ManageIQ"
        end
        if organization == "rails"
          labels << "Rails"
        end
        if organization == "rspec"
          labels << "RSpec"
        end
        labels
      end

      def organization
        headers["List-ID"].match(/^\w+(?=\/)/)[0]
      end

      def repo
        # TODO
      end

      def reason
        headers["X-GitHub-Reason"]
      end

      def headers
        @headers ||= @message.payload.headers.reduce({}) do |hash, header|
          hash.tap { |h| h[header.name] = header.value }
        end
      end

      def body
        @body ||= @message.payload.parts[0].body.data
      end
    end
  end
end
