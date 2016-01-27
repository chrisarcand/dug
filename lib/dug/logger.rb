module Dug
  module Logger
    def log(message, level: :info)
      puts "[#{level.to_s.upcase}] #{Time.now} - #{message}"
    end
  end
end
