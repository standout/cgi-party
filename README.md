# CGIParty
CGIParty is a gem made for integrating against the CGI Group GRP API.
As of now you can only perform bankid authorisation.

- *You will need a agreement with CGI group in order to user their API. We do not provide this.*

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cgi_party'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cgi_party

### Configuration
To use the gem you must configure some settings.
Here is the settings available:
```ruby
CGIParty.configure do |config|
  # (Optional) The number of seconds a poll operation will be active before timeout. Recommended is 180 seconds.
  config.collect_polling_timeout = 180

  # (Optional) The number of seconds a poll operation will wait between each call. Recommended 3 seconds.
  config.collect_polling_delay = 3

  # (Optional) The path where the WSDL is located. Change to CGIParty::TEST_PATH in development and testing
  config.wsdl_path = CGIParty::WSDL_PATH

  # (Required) The name that will be displayed in the BankID app. "Jag legitimerar mig mot #{display_name}"
  config.display_name = "display_name"

  # (Required) An identifier for your service provided by CGI Group
  config.service_id = "service_id"
end
```

## Usage
Before doing any consecutive requests you must first initiate a client and call
the authenticate method. The authenticate response will contain information about
the authentication order.
```ruby
client = CGIParty.client
authenticate_response = client.authenticate(social_security_number)
```

You can acquire an url for prompting the BankID application on the device.
```ruby
authenticate_response.autostart_url(return_url)
#=> "bankid:///?autostarttoken=[token]&redirect=[return_url]"
```

To poll the collect action you can use the poll collect method. The block will be yielded
every time the API responds. You can take appropriate action in your application by using the provided
progress statuses.

You can read more about them in the CGI Group GRP API documentation:
https://www.cgi.se/sites/default/files/files_se/pdf/grp_api.pdf
```ruby
client.poll_collect(authenticate_response.order_ref,
                    authenticate_response.transaction_id) do |collect_response|
  case collect_response.progress_status
  when "OUTSTANDING_TRANSACTION"    # Awaiting BankID application to start. (Might need manual boot)
  when "EXPIRED_TRANSACTION"        # No activity from the user after 180s.
  when "ALREADY_IN_PROGRESS"        # An order for the user is already in progress.
  when "INVALID_PARAMETERS"         # Invalid parameters provided.
  when "ACCESS_DENIED_RP"           # Internal access problem. Contact CGI.
  when "CERTIFICATE_ERR"            # The users BankID are revoked or invalid.
  when "INTERNAL_ERROR"             # An internal BankID error occured.
  when "START_FAILED"               # BankID client did't start after 30s
  when "USER_CANCEL"                # The order was canceled by the user.
  when "CLIENT_ERR"                 # An internal BankID error occurred.
  when "CANCELLED"                  # The order was cancelled.
  when "NO_CLIENT"                  # Users BankID was not available
  when "COMPLETE"                   # The authentication is completed
  when "RETRY"                      # A temporary error has occurred. Prompt the user to try again.
  end
end
```

A successful collect response will contain attributes about the authenticated person.
```ruby
collect_response.attributes
#=>
[
  { name: "cn", value: "Bob Basil" },
  { name: "serialnumber", value: "680916-1794" },
  # ...
]
```

## Development and testing
When testing the functionality against the API it is preferable to not use
the real endpoints. By changing the `wsdl_path` config variable in testing you can
change all requests to enpoints made for testing.
```ruby
CGIParty.configure do |config|
  config.wsdl_path = CGIParty::WSDL_TEST_PATH
  # ...
end
```
## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
