module Dug
  class MessageProcessor
    # Private API for processing individual Gmail messages

    include Dug::Logger

    def initialize(message_id, servicer)
      @servicer = servicer
      @message  = NotificationDecorator.new(servicer.get_user_message('me', message_id))
    end

    def execute
      LABEL_RULE_TYPES.each do |type|
        if message.public_send(type) && label = Dug.configuration.label_for(type, message.public_send(type))
          labels_to_add << label
        end
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
      @labels_to_remove ||= [Dug.configuration.unprocessed_label_name]
    end

    private

    attr_reader :message
    attr_reader :servicer

  end
end
