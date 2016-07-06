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
          Dug::MessageProcessor.new(message.id, servicer).execute
        end
        log("Finished processing #{unprocessed_notifications.size} GitHub notifications.")
      else
        log("No new GitHub notifications.")
      end
    end

    private

    def unprocessed_notifications(use_cache: true)
      unless use_cache
        log("Requesting latest emails from Gmail...")
        @unprocessed_notifications = nil
      end
      unprocessed_label = servicer.labels(use_cache: use_cache)[Dug.configuration.unprocessed_label_name]
      raise "Create the label '#{Dug.configuration.unprocessed_label_name}' on gmail" unless unprocessed_label

      # The reverse! is required because we want to process messages in order
      # and Google doesn't allow you to sort by anything because labels. Order
      # is required here to account for state changes like reopened issues
      @unprocessed_notifications ||=
        begin
          messages = servicer
            .list_user_messages('me', label_ids: [unprocessed_label.id])
            .messages
          messages.reverse! if messages
        end
    end

    def unprocessed_notifications?
      !!unprocessed_notifications(use_cache: false)
    end
  end
end
