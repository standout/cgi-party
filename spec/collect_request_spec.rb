require "cgi_party/collect_request"

RSpec.describe CGIParty::CollectRequest do
  describe ".initialize" do
    it "sets the order reference" do
      expect(CGIParty::CollectRequest.new(CGIParty::Client.new.savon_client,
                                          "order_reference").order_reference)
        .to eq("order_reference")
    end

    it "sets the transaction id if provided" do
      expect(CGIParty::CollectRequest.new(CGIParty::Client.new.savon_client,
                                          "order_reference",
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
                                             "transaction_id")

      request.execute

      expect(savon_client).to have_received(:call).with(:collect, any_args)
    end

    it "provides the necessary details" do
      CGIParty::Client.new
      savon_client = spy("savon_client")
      request = CGIParty::CollectRequest.new(savon_client,
                                             "order_reference",
                                             "transaction_id")

      request.execute

      expect(savon_client).to have_received(:call).with(:collect, message: {
        policy: CGIParty.config.service_id,
        provider: CGIParty.config.provider,
        rp_display_name: CGIParty.config.display_name,
        transaction_id: "transaction_id",
        order_ref: "order_reference",
      }, message_tag: "CollectRequest", soap_action: false)
    end

    it "returns a collect response" do
      savon.mock!
      savon_client = CGIParty::Client.new.savon_client
      request = CGIParty::CollectRequest.new(savon_client,
                                             "order_reference",
                                             "transaction_id")
      response_xml = File.read("spec/fixtures/collect_response.xml")
      savon.expects(:collect).with(message: :any).returns(response_xml)

      result = request.execute

      expect(result).to be_an_instance_of(CGIParty::CollectResponse)

      savon.unmock!
    end
  end
end
