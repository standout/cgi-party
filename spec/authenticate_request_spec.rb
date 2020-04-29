require "cgi_party/authenticate_request"

RSpec.describe CGIParty::AuthenticateRequest do
  let(:ip_address) { '127.0.0.1' }

  describe ".initialize" do
    it "sets ssn" do
      ssn = "5907269129"

      request =
        CGIParty::AuthenticateRequest.new(CGIParty::Client.new.savon_client,
                                          ssn,
                                          ip_address)

      expect(request.ssn).to eq ssn
    end
  end

  describe "#execute" do
    include Savon::SpecHelper

    it "calls the appropriate soap action" do
      ssn = "5907269129"
      savon_client = spy("savon_client")
      request = CGIParty::AuthenticateRequest.new(savon_client, ssn, ip_address)

      request.execute

      expect(savon_client).to have_received(:call).with(:authenticate, any_args)
    end

    it "provides the necessary details" do
      ssn = "5907269129"
      savon_client = spy("savon_client")
      request = CGIParty::AuthenticateRequest.new(savon_client, ssn, ip_address)

      request.execute

      expect(savon_client).to have_received(:call).with(
        :authenticate,
        message: {
          display_name: CGIParty.config.display_name,
          provider: CGIParty.config.provider,
          policy: CGIParty.config.service_id,
          end_user_info: {
            type: 'IP_ADDR',
            value: '127.0.0.1'
          },
          personal_number: ssn,
        }, message_tag: "AuthenticateRequest"
      )
    end

    it "returns an order response" do
      savon.mock!
      ssn = "5907269129"
      savon_client = CGIParty::Client.new.savon_client
      request = CGIParty::AuthenticateRequest.new(savon_client, ssn, ip_address)
      response_xml = File.read("spec/fixtures/authenticate_response.xml")
      savon.expects(:authenticate).with(message: :any).returns(response_xml)

      result = request.execute

      expect(result).to be_an_instance_of(CGIParty::AuthenticateResponse)

      savon.unmock!
    end
  end
end
