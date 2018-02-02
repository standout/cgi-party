RSpec.describe CGIParty::AuthenticateResponse do
  it "must set attributes" do
    response_body = {
      :authenticate_response=> {
        :transaction_id=>"e7a5c17c",
        :order_ref=>"c87ebe55-0d1d-4d37-a5ed-c0b65f88c4e4",
        :auto_start_token=>"45216ad0-320a-4de5-b4a3-bac28de5c173",
      }
    }

    response = CGIParty::AuthenticateResponse.new(response_body)

    expect(response.transaction_id).to eq response_body[:authenticate_response][:transaction_id]
    expect(response.order_ref).to eq response_body[:authenticate_response][:order_ref]
    expect(response.auto_start_token).to eq response_body[:authenticate_response][:auto_start_token]
  end
end
