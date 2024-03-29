module CGIParty
  class Request
    def initialize(savon_client, ip_address = nil, options)
      @options = fetch_options(options, available_options)
      @savon_client = savon_client
      @ip_address = ip_address
    end

    def execute
      response = @savon_client.call(action_name, message: message_hash, message_tag: message_tag, soap_action: false)
      serialize_data(response.body)
    end

    private

    def fetch_options(options, available_options)
      available_options.each do |option_name|
        options[option_name] ||= CGIParty.config.public_send(option_name)
      end

      options
    end

    # Only works for single word actions
    def action_name
      message_tag[/(.*)(?:Request)/, 1].downcase.to_sym
    end

    def message_tag
      self.class.name.gsub(/^.*::/, '')
    end

    def end_user_info
      {
        type: 'IP_ADDR',
        value: @ip_address
      }
    end
  end
end
