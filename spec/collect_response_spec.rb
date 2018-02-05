RSpec.describe CGIParty::CollectResponse do
  def response_with_status(status)
    CGIParty::CollectResponse.new(
      {
        collect_response: {
          transaction_id: "transaction_id",
          progress_status: status
        }
      })
  end

  it "must set attributes" do
    response_body = {
      :authenticate_response=> {
        :transaction_id=>"e7a5c17c",
        :progress_status=>"NO_CLIENT",
      }
    }

    response = CGIParty::CollectResponse.new(response_body)

    expect(response.transaction_id).to eq response_body[:authenticate_response][:transaction_id]
    expect(response.progress_status).to eq response_body[:authenticate_response][:progress_status]
  end

  describe "#authentication_finished?" do
    it "must return false if ongoing" do
      allow_any_instance_of(CGIParty::CollectResponse).to receive(:authentication_ongoing?).and_return(true)
      expect(response_with_status("OUTSTANDING_TRANSACTION").authentication_finished?).to eq false
    end

    it "must return true if not ongoing" do
      allow_any_instance_of(CGIParty::CollectResponse).to receive(:authentication_ongoing?).and_return(false)
      expect(response_with_status("NO_CLIENT").authentication_finished?).to eq true
    end
  end

  describe "#authentication_ongoing?" do
    it "must return true if it has an ongoing status" do
      expect(response_with_status("OUTSTANDING_TRANSACTION").authentication_ongoing?).to eq true
      expect(response_with_status("USER_SIGN").authentication_ongoing?).to eq true
    end

    it "must return false if any other status" do
      expect(response_with_status("COMPLETE").authentication_ongoing?).to eq false
      expect(response_with_status("NO_CLIENT").authentication_ongoing?).to eq false
      expect(response_with_status("STARTED").authentication_ongoing?).to eq false
    end
  end
end
