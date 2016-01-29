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
        ["GitHub"] + organization_labels + repository_labels + reason_labels
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
        Dug.configuration.labels_for(:reason, name: reason_name) || []
      end

      def organization_labels
        Dug.configuration.labels_for(:organization, name: organization_name) || []
      end

      def repository_labels
        Dug.configuration.labels_for(:repository,
                                     name: repository_name,
                                     organization: organization_name) || []
      end

      def organization_name
        headers["List-ID"].match(/^([\w\-_]+)\//)[0]
      end

      def repository_name
        headers["List-ID"].match(/^\w+\/([\w\-_]+)/)[0]
      end

      def reason_name
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
