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

      # HACK: The 'reverse!' here, sort of. This mitigates trouble processing state changes because of message order.
      # The Gmail API always provides them date descending and gives no order querying (indeed, with labels they don't
      # even allow you to sort in the Gmail UI!). So if someone closes/reopens an issue, the reopen will be processed
      # first and closed after, resulting in a final state of...closed.
      #
      # This could possibly be corrected in the future by taking the entire thread in to account if it's a state change,
      # but with the message-by-message implementation currently set up, this is a hack that will fix *most* cases.
      @unprocessed_notifications ||= servicer
        .list_user_messages('me', label_ids: [unprocessed_label.id])
        .messages
        .reverse!
    end

    def unprocessed_notifications?
      !!unprocessed_notifications(use_cache: false)
    end
  end
end
