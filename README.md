# CGIParty
CGIParty is a gem made for integrating against the CGI Group GRP2 API.
As of now you can only perform BankID authorization.

- *You will need an agreement with CGI group in order to user their API. We do not provide this.*

**NOTE: If you're still using the old GRP API, you'll need to install the old version ([1.0.0](https://github.com/standout/cgi-party/tree/v1.0.0)) of this gem.**

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

  # (Optional) The number of seconds a poll operation will wait between each call. Recommended is 3 seconds.
  config.collect_polling_delay = 3

  # (Optional) The path where the WSDL is located. Change to CGIParty::WSDL_TEST_PATH in development and testing
  config.wsdl_path = CGIParty::WSDL_PATH

  # (Required) The name that will be displayed in the BankID app. "Jag legitimerar mig mot #{display_name}"
  config.display_name = "display_name"

  # (Required) An identifier for your service provided by the CGI Group
  config.service_id = "service_id"
end
```

## Usage
Before doing any consecutive requests you must first initiate a client and call
the authenticate method. The authenticate response will contain information about
the authentication order.
```ruby
client = CGIParty::Client.new
authenticate_response = client.authenticate(ip_address)
```
### Autostart on the same device
You can acquire an url for prompting the BankID application on the device.
```ruby
authenticate_response.autostart_url(return_url)
#=> "bankid:///?autostart=[token]&return=[return_url]"
```

### QR code for BankID on another device
Generate an animated QR code. You'll need some way to keep track of elapsed seconds as you refresh the QR code.
```ruby
client.generate_qr(start_token: authenticate_response.qr_start_token,
                   start_secret: authenticate_response.qr_start_secret,
                   seconds: seconds_elapsed)
```

### Collect
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
