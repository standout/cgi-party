module CGIParty
  class Client
    def initalize
      @savon_client = Savon.client(wsdl: CGIParty::WSDL_PATH)
    end
  end
end
