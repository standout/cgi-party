RSpec.describe CGIParty::Client do
  describe "#poll_collect" do
    let(:order_ref) { "c87ebe55-0d1d-4d37-a5ed-c0b65f88c4e4" }
    before { allow_any_instance_of(CGIParty::Client).to receive(:sleep) }


    it "calls collect" do
      client = CGIParty::Client.new
      response = CGIParty::CollectResponse.new({ collect_response: { progress_status: "COMPLETE"} })
      allow(client).to receive(:collect).and_return(response)

      client.poll_collect(order_ref) {}

      expect(client).to have_received(:collect)
    end

    it "must timeout" do
      client = CGIParty::Client.new
      response = CGIParty::CollectResponse.new({ collect_response: { progress_status: "COMPLETE"} })
      allow(client).to receive(:collect).and_return(response)

      client.poll_collect(order_ref) do
        # Makes the first collect action 180 seconds long
        Timecop.travel Time.now + 180
      end

      expect(client).to have_received(:collect).once
    end

    it "calls collect until authentication is considered finished" do
      client = CGIParty::Client.new
      allow(client).to receive(:collect).and_return(
          collect_response_with_status("OUTSTANDING_TRANSACTION"),
          collect_response_with_status("USER_SIGN"),
          collect_response_with_status("COMPLETE")
      )

      client.poll_collect(order_ref) {}

      expect(client).to have_received(:collect).exactly(3).times
    end

    it "must wait between each request" do
      client = CGIParty::Client.new
      allow(client).to receive(:collect)
        .and_return(
          collect_response_with_status("OUTSTANDING_TRANSACTION"),
          collect_response_with_status("COMPLETE")
        )

      client.poll_collect(order_ref) {}

      expect(client).to have_received(:sleep).with(CGIParty.config.collect_polling_delay).once
    end

    it "yields a block with the current collect response status" do
      client = CGIParty::Client.new
      response = collect_response_with_status("COMPLETE")
      expect(client).to receive(:collect).ordered.and_return response

      expect do |b|
        client.poll_collect(order_ref, &b)
      end.to yield_with_args(response)
    end
  end

  def collect_response_with_status(status)
    CGIParty::CollectResponse.new(
      {
        collect_response: {
          transaction_id: "transaction_id",
          progress_status: status
        }
      }
    )
  end
end
