RSpec.describe CGIParty::AuthenticateResponse do
  it "must set attributes" do
    response_body = {
      :authenticate_response=> {
        :transaction_id=>"e7a5c17c",
        :order_ref=>"c87ebe55-0d1d-4d37-a5ed-c0b65f88c4e4",
        :auto_start_token=>"45216ad0-320a-4de5-b4a3-bac28de5c173"
      }
    }

    response = CGIParty::AuthenticateResponse.new(response_body)

    expect(response.transaction_id).to eq response_body[:authenticate_response][:transaction_id]
    expect(response.order_ref).to eq response_body[:authenticate_response][:order_ref]
    expect(response.auto_start_token).to eq response_body[:authenticate_response][:auto_start_token]
  end

  describe "#autostart_url" do
    let(:return_url) { "my_return_url" }
    let(:authenticate_response) do
      CGIParty::AuthenticateResponse.new({
        :authenticate_response=> {
          :transaction_id=>"e7a5c17c",
          :order_ref=>"c87ebe55-0d1d-4d37-a5ed-c0b65f88c4e4",
          :auto_start_token=>"45216ad0-320a-4de5-b4a3-bac28de5c173"
        }
      })
    end

    subject { authenticate_response.autostart_url(return_url) }

    it "must use the bankid protocol" do
      expect(subject).to include "bankid:///"
    end

    it "must include autostart token in the query parameters" do
      expect(subject).to include authenticate_response.auto_start_token
    end

    it "must use the provided return url in the query parameterss" do
      expect(subject).to include return_url
    end
  end
end
