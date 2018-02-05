require "cgi_party/authenticate_request"
require "cgi_party/collect_request"
require "cgi_party/wsdl_paths"
require "cgi_party/version"
require "cgi_party/client"

module CGIParty
  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Configuration.new
    yield(config)
  end

  class Configuration
    attr_accessor :service_id
    attr_accessor :display_name
    attr_accessor :provider
    attr_accessor :wsdl_path

    def initialize
      @service_id = "service_id"
      @display_name = "display_name"
      @provider = "bankid"
      @wsdl_path = WSDL_PATH
    end
  end
end
