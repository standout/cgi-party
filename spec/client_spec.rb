RSpec.describe CGIParty::Client do
  def collect_response_with_status(status)
    CGIParty::CollectResponse.new(
      {
        collect_response: {
          transaction_id: "transaction_id",
          progress_status: status
        }
      })
  end

  describe "#poll_collect" do
    include Savon::SpecHelper

    before { allow_any_instance_of(CGIParty::Client).to receive(:sleep) }
    let(:order_ref) { "c87ebe55-0d1d-4d37-a5ed-c0b65f88c4e4" }
    let(:client) { CGIParty::Client.new }
    before(:all) { savon.mock! }
    after(:all) { savon.unmock! }


    it "must call authenticate and collect" do
      savon.expects(:collect).with(message: :any).returns(File.read("spec/fixtures/collect_response.xml"))

      client.poll_collect(order_ref) {}
    end

    it "must timeout after 180 seconds of polling" do
      expect(client).to receive(:collect).ordered.once # Initial collect
      expect(client).to receive(:polling_duration).and_return(180)
      expect(client).to receive(:collect).ordered.never

      client.poll_collect(order_ref) {}
    end

    it "must call collect until authentication is considered finished" do
      expect(client).to receive(:collect).exactly(3).times
        .and_return(
          collect_response_with_status("OUTSTANDING_TRANSACTION"),
          collect_response_with_status("USER_SIGN"),
          collect_response_with_status("COMPLETE")
        )

      client.poll_collect(order_ref) {}
    end

    it "must wait 3 seconds between each request" do
      expect(client).to receive(:collect)
        .and_return(
          collect_response_with_status("OUTSTANDING_TRANSACTION"),
          collect_response_with_status("COMPLETE")
        )
      expect(client).to receive(:sleep).ordered.with(3)

      client.poll_collect(order_ref) {}
    end

    it "must yield a block with the current collect response status" do
      response = collect_response_with_status("COMPLETE")
      expect(client).to receive(:collect).ordered.and_return response

      expect {|b|
        client.poll_collect(order_ref, &b)
      }.to yield_with_args(response)
    end
  end

  describe "#authenticate" do
    let(:client) { CGIParty::Client.new }

    it "must do an authenticate request" do
      expect_any_instance_of(CGIParty::AuthenticateRequest)
        .to receive(:execute).and_return({})

      client.authenticate("6405113090")
    end
  end

  describe "#collect" do
    let(:client) { CGIParty::Client.new }

    it "must do a collect request" do
      expect_any_instance_of(CGIParty::CollectRequest)
        .to receive(:execute).and_return({})

      client.collect("order_reference", "transaction_id")
    end
  end
end
