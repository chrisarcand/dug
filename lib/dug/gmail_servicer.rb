require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'forwardable'

module Dug
  class GmailServicer
    extend Forwardable

    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
    APPLICATION_NAME = 'GitHub Notification Processor'
    TOKEN_STORE_PATH = File.join(Dir.home, '.dug', "authorization.yaml")
    SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_MODIFY

    def_delegators :@gmail, :get_user_message,
                            :list_user_messages,
                            :modify_message

    def initialize
      @gmail = Google::Apis::GmailV1::GmailService.new
      @gmail.client_options.application_name = APPLICATION_NAME
    end

    def labels(use_cache: true)
      @labels = nil unless use_cache
      @labels ||= @gmail.list_user_labels('me').labels.reduce({}) do |hash, label|
        hash.tap { |h| h[label.name] = label }
      end
    end

    def add_labels_by_name(*args)
      modify_message_request(*args) do |request, ids|
        request.add_label_ids = ids
      end
    end

    def remove_labels_by_name(*args)
      modify_message_request(*args) do |request, ids|
        request.remove_label_ids = ids
      end
    end

    # TODO: break some of this code down, prolly into a separate Authorizer class or something
    def authorize!
      token_store_path = ENV['GOOGLE_TOKEN_STORE_PATH'] || File.join(Dir.home, '.dug', "token_store.yaml")
      FileUtils.mkdir_p(File.dirname(token_store_path))

      client_id = begin
                    if Dug.configuration.client_id
                      Google::Auth::ClientId.new(Dug.configuration.client_id,
                                                 Dug.configuration.client_secret)
                    else
                      Google::Auth::ClientId.from_file(Dug.configuration.application_credentials_file)
                    end
                  end
      token_store = Google::Auth::Stores::FileTokenStore.new(file: token_store_path)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
      user_id = 'default'

      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(
          base_url: OOB_URI)
        puts "Open the following URL in the browser and enter the " +
          "resulting code after authorization"
        puts url
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI)
      end
      @gmail.authorization = credentials
    end

    private

    def modify_message_request(message, label_names)
      ids = []
      label_names.each do |name|
        unless labels[name] && id = labels[name].id
          raise MissingLabel, "The label '#{name}' does not exist. Please add the label in Gmail first."
        end
        ids << id
      end
      request = Google::Apis::GmailV1::ModifyMessageRequest.new
      yield request, ids
      modify_message('me', message.id, request)
    end
  end

  MissingLabel = Class.new(StandardError)
end
