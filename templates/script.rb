require 'dug'

Dug.configure do |config|
 # You can alternatively pass environment variables
 # or a path to a downloadable authentication .json file from Google
 config.client_id = "<google oauth client id>"
 config.client_secret = "<google secret>"

 config.rule_file = File.join(Dir.pwd, "/dug/dug_rules.yml")
end
loop do
  begin
    Dug::Runner.run
    sleep 180
  rescue => e
    puts "Error connecting to Gmail: #{e.inspect}"
  end
end
