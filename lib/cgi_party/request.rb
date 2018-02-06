module CGIParty
  class Request
    def initialize(savon_client, options)
      @savon_client = savon_client
      @options = fetch_options(options, available_options)
    end

    def execute
      serialize_data(
        @savon_client.call(
          action_name,
          message: message_hash,
          message_tag: message_tag
        ).body
      )
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
  end
end
