require "cgi_party/collect_request"

RSpec.describe CGIParty::CollectRequest do
  let(:ip_address) { '127.0.0.1' }

  describe ".initialize" do
    it "sets the order reference" do
      expect(CGIParty::CollectRequest.new(CGIParty::Client.new.savon_client,
                                          "order_reference",
                                          ip_address).order_reference)
        .to eq("order_reference")
    end

    it "sets the transaction id if provided" do
      expect(CGIParty::CollectRequest.new(CGIParty::Client.new.savon_client,
                                          "order_reference",
                                          ip_address,
                                          "transaction_id").transaction_id)
        .to eq("transaction_id")
    end
  end

  describe "#execute" do
    include Savon::SpecHelper

    it "calls the appropriate soap action" do
      CGIParty::Client.new
      savon_client = spy("savon_client")
      request = CGIParty::CollectRequest.new(savon_client,
                                             "order_reference",
                                             ip_address,
                                             "transaction_id")

      request.execute

      expect(savon_client).to have_received(:call).with(:collect, any_args)
    end

    it "provides the necessary details" do
      CGIParty::Client.new
      savon_client = spy("savon_client")
      request = CGIParty::CollectRequest.new(savon_client,
                                             "order_reference",
                                             ip_address,
                                             "transaction_id")

      request.execute

      expect(savon_client).to have_received(:call).with(:collect, message: {
        policy: CGIParty.config.service_id,
        end_user_info: {
          type: 'IP_ADDR',
          value: '127.0.0.1'
        },
        transaction_id: "transaction_id",
        order_ref: "order_reference",
        display_name: CGIParty.config.display_name
      }, message_tag: "CollectRequest")
    end

    it "returns a collect response" do
      savon.mock!
      savon_client = CGIParty::Client.new.savon_client
      request = CGIParty::CollectRequest.new(savon_client,
                                             "order_reference",
                                             ip_address,
                                             "transaction_id")
      response_xml = File.read("spec/fixtures/authenticate_response.xml")
      savon.expects(:collect).with(message: :any).returns(response_xml)

      result = request.execute

      expect(result).to be_an_instance_of(CGIParty::CollectResponse)

      savon.unmock!
    end
  end
end
