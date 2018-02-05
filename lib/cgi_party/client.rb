require "savon"


module CGIParty
  class Client
    attr_reader :savon_client

    def initialize
      @savon_client = Savon.client(savon_opts)
    end

    def poll_authentication(ssn)
      response = authenticate(ssn)
      collect(response.order_reference)
    end

    def authenticate(ssn)
      CGIParty::AuthenticateRequest.new(@savon_client, ssn).execute
    end

    def collect(order_reference, transaction_id)
      CGIParty::CollectRequest.new(@savon_client, order_reference, transaction_id).execute
    end

    private

    def savon_opts
      {
        namespace: CGIParty::WSDL_NAMESPACE,
        namespace_identifier: :v1,
        wsdl: CGIParty::WSDL_PATH,
        env_namespace: :soapenv,
        ssl_verify_mode: :none
      }
    end
  end
end
