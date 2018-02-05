require "cgi_party/authenticate_request"

RSpec.describe CGIParty::AuthenticateRequest do
  describe ".initialize" do
    let(:ssn) { "5907269129" }
    subject { CGIParty::AuthenticateRequest.new(CGIParty::Client.new.savon_client, ssn) }

    it "must set ssn" do
      expect(subject.ssn).to eq ssn
    end
  end

  describe "#execute" do
    include Savon::SpecHelper

    before(:all) { savon.mock!   }
    after(:all)  { savon.unmock! }
    let(:ssn) { "5907269129" }
    subject { CGIParty::AuthenticateRequest.new(CGIParty::Client.new.savon_client, ssn) }
    let(:response_xml) { File.read("spec/fixtures/authenticate_response.xml") }

    it "must call the appropiate soap action" do
      savon.expects(:authenticate).with(message: :any).returns(response_xml)

      subject.execute
    end

    it "must provide the necessary details" do
      savon.expects(:authenticate).with(message: {
        display_name: CGIParty.config.display_name,
        policy: CGIParty.config.service_id,
        provider: CGIParty.config.provider,
        personal_number: ssn
      }).returns(response_xml)

      subject.execute
    end

    it "must return an order response" do
      savon.expects(:authenticate).with(message: :any).returns(response_xml)

      result = subject.execute

      expect(result).to be_an_instance_of(CGIParty::AuthenticateResponse)
    end
  end
end
