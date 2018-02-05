require "cgi_party/authenticate_response"
require "cgi_party/request"

module CGIParty
  class AuthenticateRequest
    include CGIParty::Request
    attr_reader :service_id, :display_name, :provider, :ssn

    def initialize(savon_client, ssn)
      @savon_client = savon_client
      @ssn = ssn
    end

    private

    def serialize_data(data)
      CGIParty::AuthenticateResponse.new(data)
    end

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
