require 'dug'

Dug.configure do |config|
 # You can alternatively pass environment variables
 # or a path to a downloadable authentication .json file from Google
 config.client_id = "<client-id>"
 config.client_secret = "<client-secret>"

 config.rule_file = File.join(Dir.pwd, "dug_rules.yml")
end

Dug::Runner.run
