require "savon"

module CGIParty
  class AuthenticateRequest
    attr_reader :service_id, :display_name, :provider, :ssn

    def initialize(savon_client, ssn)
      @savon_client = savon_client
      @ssn = ssn
    end

    def execute
      @savon_client.call(:authenticate, message: message_hash).body
    end

    private

    def message_hash
      {
        display_name: CGIParty.config.display_name,
        provider: CGIParty.config.provider,
        policy: CGIParty.config.service_id,
        personal_number: @ssn
      }
    end
  end
end
