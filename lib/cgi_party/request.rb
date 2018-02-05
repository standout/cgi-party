module CGIParty
  module Request
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

    # Only works for single word actions
    def action_name
      message_tag[/(.*)(?:Request)/, 1].downcase.to_sym
    end

    def message_tag
      self.class.name.gsub(/^.*::/, '')
    end
  end
end
