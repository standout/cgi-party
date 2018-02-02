require "savon"

module CGIParty
  class Client
    attr_reader :savon_client

    def initialize
      @savon_client = Savon.client(wsdl: CGIParty::WSDL_PATH,
                                   ssl_verify_mode: :none)
    end
  end
end
