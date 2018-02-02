module CGIParty
  module Request
    def execute
      @savon_client.call(action_name, message: message_hash)
    end

    private

    # Only works for single word actions
    def action_name
      self.class
          .name
          .gsub(/^.*::/, '')[/(.*)(?:Request)/, 1]
          .downcase
          .to_sym
    end
  end
end
