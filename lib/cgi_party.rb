require "cgi_party/version"
require "cgi_party/wsdl_path"
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

    def initialize
      @service_id = "service_id"
      @display_name = "display_name"
      @provider = "bankid"
    end
  end
end
