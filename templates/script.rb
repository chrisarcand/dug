require 'dug'
cert_path = Gem.loaded_specs['google-api-client'].full_gem_path+'/lib/cacerts.pem'
ENV['SSL_CERT_FILE'] = cert_path

Dug.configure do |config|
 # You can alternatively pass environment variables
 # or a path to a downloadable authentication .json file from Google
 config.client_id = "<google client id>"
 config.client_secret = "<google client secret>"

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
