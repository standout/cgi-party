RSpec.describe CGIParty::CollectResponse do
  it "must set attributes" do
    response_body = {
      :authenticate_response=> {
        :transaction_id=>"e7a5c17c",
        :progress_status=>"NO_CLIENT",
      }
    }

    response = CGIParty::AuthenticateResponse.new(response_body)

    expect(response.transaction_id).to eq response_body[:authenticate_response][:transaction_id]
    expect(response.progress_status).to eq response_body[:authenticate_response][:progress_status]
  end
end
