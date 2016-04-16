module Dug
  module Util
    def pluralize(singular)
      if singular =~ /y\z/
        singular.gsub(/(y)\z/, "ies")
      else
        "#{singular}s"
      end
    end
    module_function :pluralize
  end
end
