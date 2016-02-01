module Dug
  class Runner
    include Dug::Logger

    attr_reader :servicer

    def self.run(*args)
      new.run(*args)
    end

    def initialize
      @servicer = Dug::GmailServicer.new
      servicer.authorize!
    end

    def run
      if unprocessed_notifications?
        log("Processing #{unprocessed_notifications.size} GitHub notifications...")
        unprocessed_notifications.each do |message|
          process_message(message.id)
        end
        log("Finished processing #{unprocessed_notifications.size} GitHub notifications.")
      else
        log("No new GitHub notifications.")
      end
    end

    private

    def process_message(id)
      message = NotificationDecorator.new(servicer.get_user_message('me', id))

      labels_to_add    = ["GitHub"]
      labels_to_remove = ["GitHub/Unprocessed"]
      if message.reason
        labels_to_add << Dug.configuration.label_for(:reason, name: message.reason)
      end
      labels_to_add << Dug.configuration.label_for(:organization, name: message.organization)
      labels_to_add << Dug.configuration.label_for(:repository,
                                                   name: message.repository,
                                                   organization: message.organization)
      labels_to_add.flatten! and labels_to_remove.flatten!
      labels_to_add.compact! and labels_to_remove.compact!

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

    def unprocessed_notifications(use_cache: true)
      unless use_cache
        log("Requesting latest emails from Gmail...")
        @unprocessed_notifications = nil
      end
      unprocessed_label = servicer.labels(use_cache: use_cache)["GitHub/Unprocessed"]
      @unprocessed_notifications ||= servicer
        .list_user_messages('me', label_ids: [unprocessed_label.id])
        .messages
    end

    def unprocessed_notifications?
      !!unprocessed_notifications(use_cache: false)
    end
  end
end
