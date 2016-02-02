# Dug
[![Gem Version](https://badge.fury.io/rb/dug.svg)](https://badge.fury.io/rb/dug)
[![Build Status](https://travis-ci.org/chrisarcand/dug.svg?branch=master)](https://travis-ci.org/chrisarcand/dug)
[![Code Climate](https://codeclimate.com/github/chrisarcand/dug/badges/gpa.svg)](https://codeclimate.com/github/chrisarcand/dug)
[![Test Coverage](https://codeclimate.com/github/chrisarcand/dug/badges/coverage.svg)](https://codeclimate.com/github/chrisarcand/dug/coverage)

Created out of frustration. _"[D]amn yo[u], [G]mail!"_

**Dug is a simple, configurable gem to organize your GitHub notification emails in
ways Gmail can't and in an easier-to-configure way.** It interacts with Google's
Gmail API to do all the things that people usually do with Gmail filters (label by
organization name, repository name) as well as parse GitHub's custom X headers to
label your messages with things like "Mentioned by name", "Assigned to me",
"Commented", etc.


## Quick Installation

Dug is meant to be stupid simple. It's practically a gemified script with a
configurable API. As such, you can programmatically configure and execute Dug's
runner class in any way you see fit (within a web app hook, a Rake task, a script,
whatever).

Basic installation steps:

1. Install Dug

  ```
  $ gem install dug
  ```

2. Create a YAML Rule file. Example (`dug_rules.yml`):

  ```
  ---
  organizations:
    - rails
    - name: rspec
      label: RSpec
      repositories:
        - name: rspec-expectations
          label: RSpec/rspec-expectations
    - ManageIQ

  reasons:
    author:
      label: Participating
    comment:
      label: Participating
    mention:
      label: Mentioned by name
    team_mention:
      label: Team mention
    assign:
      label: Assigned to me
  ```

  The above rule file will:
  * Label all notifications from the organization `rails` with the label `rails`, `rspec` with `RSpec`, `ManageIQ` with `ManageIQ`.
  * Label all notifications from the repository `rspec-expectations` with the label `RSpec/rspec-expectations`
  * Label notifications with `Participating` if I am the author of the Issue/PR or if I commented on it.
  * Label notifications with `Mentioned by name` if I'm directly mentioned in it.
  * Label notifications with `Team mention` if a team I am a part of is mentioned in it.
  * Label notifications with `Assigned to me` if the Issue/PR is assigned to me.

3. In Gmail, create the label "GitHub" and then "Unprocessed" nested underneath it (will show up as "GitHub/Processed").
   In addition, create all of the labels in the preceding step if you don't have them already.

4. Create a project in the [Google Developers Console](https://console.developers.google.com) to authenticate to the
   Gmail API via OAuth 2.0. If you need help, detailed instructions are included further in this document.

5. Create a script. Example (`script.rb`; fill in your OAuth credentials):

   ```ruby
   require 'dug'

   Dug.configure do |config|
     # You can alternatively pass environment variables
     # or a path to a downloadable authentication .json file from Google
     config.client_id = "lja8w34jfo8ajer9vjsoasdufo98auow34f.apps.googleusercontent.com"
     config.client_secret = "34t998asDF9879hjfd"

     config.rule_file = File.join(Dir.pwd, "dug_rules.yml")
   end

   Dug::Runner.run
   ```

6. Run the script and watch your notifications get organized! The first time your run this you will be given a link to
   visit in your browser to sign in to Gmail verify via a one time token.

  ```
  $ ruby script.rb
  ```

7. Set a cron and forget about it (this is what I do, 60 second polling). Or deploy Dug in a web application. Or even
   just write a loop in your script `loop do; Dug::Runner.run; sleep 60; end`. How you run it is completely up to you,
   and really doesn't matter.

For more help, see verbose instructions below.

## Verbose Installation/Usage

Dug requires MRI 2.1+. Tests pass on the latest versions of JRuby and Rubinius as well.

### Creating OAuth 2.0 credentials to the Gmail API

[Create a project named "Dug" in the Google Developers Console and enable the Gmail
API.](https://console.developers.google.com//start/api?id=gmail&credential=client_key)  
Using this link guides you through the process and activates the Gmail API automatically.

For more information, see [Using OAuth 2.0 to Access Google APIs](https://developers.google.com/identity/protocols/OAuth2)

#### Using the created OAuth credentials

There are multiple ways to use created OAuth credentials with Dug.

* You can set the environment variables `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` for the OAuth client ID and secret, respectively.
* In the Google Developer Console, in Credentials, there is an option to download a JSON file containing client credentials. You may set
  the environment variable `GOOGLE_APPLICATION_CREDENTIALS` as a path to this file and it will be used.
* You can set the client ID and secret OR credentials file path as mentioned above directly in a Dug configuration block:

  ```ruby
  Dug.configure do |config|
    config.client_id = "lja8w34jfo8ajer9vjsoasdufo98auow34f.apps.googleusercontent.com"
    config.client_secret = "34t998asDF9879hjfd"

    # OR

    config.application_credentials_file = "/path/to/file"
  end
  ```

#### Token store

Dug uses Google's file-based token store for refresh tokens from the [Google Auth
Library for Ruby](https://github.com/google/google-auth-library-ruby). The token
store's location can be configured using the `TOKEN_STORE_PATH` environment
variable or within the configuration block as follows:

```ruby
Dug.configure do |config|
  config.token_store = "/path/to/token/store"
end
```

### More configuration options

You can use public methods in Dug's configuration class to programmatically
configure Dug without a Rules YAML file.  As a documenting example, here is the
same scenario in the YAML file used previously in this README but within a config
block:

```ruby
Dug.configure do |config|
  config.set_organization_rule('rails')
  config.set_organization_rule('rspec', label: 'RSpec')
  config.set_organization_rule('ManageIQ')

  config.set_repository_rule('rspec-expectations', label: 'RSpec/rspec-expectations')

  config.set_reason_rule('author',       label: 'Participating')
  config.set_reason_rule('comment',      label: 'Participating')
  config.set_reason_rule('mention',      label: 'Mention by name')
  config.set_reason_rule('team_mention', label: 'Team mention')
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chrisarcand/dug.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

