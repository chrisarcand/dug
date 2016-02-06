module Dug
  class MessageProcessor
    # Private API for processing individual Gmail messages

    include Dug::Logger

    def initialize(message_id, servicer)
      @servicer = servicer
      @message  = NotificationDecorator.new(servicer.get_user_message('me', message_id))
    end

    def execute
      if message.reason && label = Dug.configuration.label_for(:reason, message.reason)
        labels_to_add << label
      end

      if label = Dug.configuration.label_for(:organization, message.organization)
        labels_to_add << label
      end

      if label = Dug.configuration.label_for(:repository, message.repository, organization: message.organization)
        labels_to_add << label
      end

      info = "Processing message:"
      info << "\n    ID: #{message.id}"
      %w(Date From Subject).each do |header|
        info << "\n    #{header}: #{message.headers[header]}"
      end
      info << "\n    * Applying labels: #{labels_to_add.join(' | ')} *"
      log(info)

      servicer.add_labels_by_name(message, labels_to_add)
      servicer.remove_labels_by_name(message, labels_to_remove)
    end

    def labels_to_add
      @labels_to_add ||= ["GitHub"]
    end

    def labels_to_remove
      @labels_to_remove ||= ["GitHub/Unprocessed"]
    end

    private

    attr_reader :message
    attr_reader :servicer

  end
end
