module Dug
  # @private
  module Logger
    # TODO This obviously needs a lot of love

    def log(message, level: :info)
      unless $testing
        puts "[#{level.to_s.upcase}] #{Time.now} - #{message}"
      end
    end
  end
end
