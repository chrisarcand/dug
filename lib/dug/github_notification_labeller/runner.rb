module Dug
  module GithubNotificationLabeller
    class Runner
      include Dug::Logger

      attr_reader :servicer

      def self.execute(*args)
        new.execute(*args)
      end

      def initialize
        @servicer = Dug::GmailServicer.new
        servicer.authorize!
      end

      def execute
        if unprocessed_notifications(use_cache: false).nil?
          log("No new GitHub notifications.")
        else
          log("Processing #{unprocessed_notifications.size} GitHub notifications...")
          unprocessed_notifications.each do |message|
            # Get full message object
            message = servicer.get_user_message('me', message.id)
            MessageProcessor.process_message!(servicer, message)
          end
          log("Finished processing #{unprocessed_notifications.size} GitHub notifications.")
        end
      end

      private

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
    end
  end
end
