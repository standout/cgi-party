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

  describe "#poll_authentication" do
    include Savon::SpecHelper

    before { allow_any_instance_of(CGIParty::Client).to receive(:sleep) }
    let(:client) { CGIParty::Client.new }
    let(:ssn) { "6405113090" }
    before(:all) { savon.mock! }
    after(:all) { savon.unmock! }


    it "must call authenticate and collect" do
      savon.expects(:authenticate).with(message: :any).returns(File.read("spec/fixtures/authenticate_response.xml"))
      savon.expects(:collect).with(message: :any).returns(File.read("spec/fixtures/collect_response.xml"))

      client.poll_authentication(ssn) {}
    end

    it "must timeout after 180 seconds of polling" do
      savon.expects(:authenticate).with(message: :any).returns(File.read("spec/fixtures/authenticate_response.xml"))
      expect(client).to receive(:polling_duration).and_return(180)
      expect(client).to receive(:collect).never

      client.poll_authentication(ssn) {}
    end

    it "must call collect until authentication is considered finished" do
      savon.expects(:authenticate).with(message: :any).returns(File.read("spec/fixtures/authenticate_response.xml"))
      expect(client).to receive(:collect).exactly(3).times
        .and_return(
          collect_response_with_status("OUTSTANDING_TRANSACTION"),
          collect_response_with_status("USER_SIGN"),
          collect_response_with_status("COMPLETE")
        )

      client.poll_authentication(ssn) {}
    end

    it "must wait 9 seconds before starting and 3 seconds between collect responses" do
      savon.expects(:authenticate).with(message: :any).returns(File.read("spec/fixtures/authenticate_response.xml"))
      expect(client).to receive(:sleep).ordered.with(9)
      expect(client).to receive(:collect).ordered.and_return collect_response_with_status("COMPLETE")

      client.poll_authentication(ssn) {}
    end

    it "must wait 3 seconds between each request" do
      savon.expects(:authenticate).with(message: :any).returns(File.read("spec/fixtures/authenticate_response.xml"))
      expect(client).to receive(:sleep).ordered.with(9)
      expect(client).to receive(:collect)
        .and_return(
          collect_response_with_status("OUTSTANDING_TRANSACTION"),
          collect_response_with_status("COMPLETE")
        )
      expect(client).to receive(:sleep).ordered.with(3)

      client.poll_authentication(ssn) {}
    end

    it "must yield a block with the current collect response status" do
      savon.expects(:authenticate).with(message: :any).returns(File.read("spec/fixtures/authenticate_response.xml"))
      expect(client).to receive(:collect).ordered.and_return collect_response_with_status("COMPLETE")

      expect {|b|
        client.poll_authentication(ssn, &b)
      }.to yield_with_args("COMPLETE")
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
