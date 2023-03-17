require "cgi_party/authenticate_response"
require "cgi_party/request"

module CGIParty
  class AuthenticateRequest < CGIParty::Request
    attr_reader :service_id, :display_name, :provider

    def initialize(savon_client, ip_address, options: {})
      super(savon_client, ip_address, options)
    end

    private

    def available_options
      %i[display_name provider service_id]
    end

    def serialize_data(data)
      CGIParty::AuthenticateResponse.new(data)
    end

    def message_hash
      {
        policy: @options[:service_id],
        provider: @options[:provider],
        rp_display_name: @options[:display_name],
        end_user_info: end_user_info
      }
    end
  end
end
