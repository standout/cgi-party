RSpec.describe CGIParty do
  it "must have a version number" do
    expect(CGIParty::VERSION).not_to be nil
  end

  it "has a WSDL path" do
    expect(CGIParty::WSDL_PATH).not_to be nil
  end
end
