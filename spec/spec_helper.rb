require "savon/mock/spec_helper"
require "bundler/setup"
require "cgi_party"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

CGIParty.configure do |config|
  config.wsdl_path = CGIParty::WSDL_TEST_PATH
  config.display_name = "display_name"
  config.service_id = "service_id"
end
