require "cgi_party/collect_request"

RSpec.describe CGIParty::CollectRequest do
  describe ".initialize" do
    it "must set the order reference" do
      expect(CGIParty::CollectRequest.new(CGIParty::Client.new.savon_client, "order_reference").order_reference)
        .to eq("order_reference")
    end

    it "must set the transaction id if provided" do
      expect(CGIParty::CollectRequest.new(CGIParty::Client.new.savon_client, "order_reference", "transaction_id").transaction_id)
        .to eq("transaction_id")
    end
  end

  describe "#execute" do
    include Savon::SpecHelper

    before(:all) { savon.mock! }
    after(:all)  { savon.unmock! }
    let(:order_reference) { "order_reference" }
    let(:transaction_id) { "transaction_id" }

    subject { CGIParty::CollectRequest.new(CGIParty::Client.new.savon_client, order_reference, transaction_id) }
    let(:response_xml) { File.read("spec/fixtures/collect_response.xml") }

    it "must call the appropiate soap action" do
      savon.expects(:collect).with(message: :any).returns(response_xml)

      subject.execute
    end

    it "must provide the necessary details" do
      savon.expects(:collect).with(message: {
        policy: CGIParty.config.service_id,
        transaction_id: transaction_id,
        order_ref: order_reference,
        display_name: CGIParty.config.display_name
      }).returns(response_xml)

      subject.execute
    end

    it "must return a collect response" do
      savon.expects(:collect).with(message: :any).returns(response_xml)

      result = subject.execute

      expect(result).to be_an_instance_of(CGIParty::CollectResponse)
    end
  end
end
