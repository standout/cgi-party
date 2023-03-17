require "cgi_party/authenticate_request"

RSpec.describe CGIParty::AuthenticateRequest do
  let(:ip_address) { '127.0.0.1' }

  describe "#execute" do
    include Savon::SpecHelper

    it "calls the appropriate soap action" do
      savon_client = spy("savon_client")
      request = CGIParty::AuthenticateRequest.new(savon_client, ip_address)

      request.execute

      expect(savon_client).to have_received(:call).with(:authenticate, any_args)
    end

    it "provides the necessary details" do
      savon_client = spy("savon_client")
      request = CGIParty::AuthenticateRequest.new(savon_client, ip_address)

      request.execute

      expect(savon_client).to have_received(:call).with(
        :authenticate,
        message: {
          policy: CGIParty.config.service_id,
          provider: CGIParty.config.provider,
          rp_display_name: CGIParty.config.display_name,
          end_user_info: {
            type: 'IP_ADDR',
            value: '127.0.0.1'
          }
        }, message_tag: "AuthenticateRequest", soap_action: false
      )
    end

    it "returns an order response" do
      savon.mock!
      savon_client = CGIParty::Client.new.savon_client
      request = CGIParty::AuthenticateRequest.new(savon_client, ip_address)
      response_xml = File.read("spec/fixtures/authenticate_response.xml")
      savon.expects(:authenticate).with(message: :any).returns(response_xml)

      result = request.execute

      expect(result).to be_an_instance_of(CGIParty::AuthenticateResponse)

      savon.unmock!
    end
  end
end
