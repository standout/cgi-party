# CGIParty

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/cgi_party`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cgi_party'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cgi_party

TODO : Add application configuration

## Usage
```ruby
client = CGIParty::Client.new(service_id: service_id)
client.authenticate(social_security_number)
#=> CGIParty::OrderResponse

client.collect(order_ref, transaction_id) #<= Should only be called once every three seconds
#=> CGIParty::CollectResponse

authenticate_response = client.authenticate
#=> CGIParty::AuthenticateResponse

authenticate_response.autostart_url
#=> #<URI>

client.poll_collect(authenticate_response.order_ref,
                    authenticate_response.transaction_id) do |collect_response|
  case collect_response.progress_status
  when "OUTSTANDING_TRANSACTION"
  when "NO_CLIENT"
  when "COMPLETE"
  when "START_FAILED"
  when "EXPIRED_TRANSACTION"
  end
end

collect_response.attributes
#=> [{ key: "name", value: "Gunnar" }]
```
## Development

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cgi_party.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
