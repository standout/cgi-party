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
    attr_accessor :collect_polling_timeout
    attr_accessor :collect_polling_delay
    attr_accessor :display_name
    attr_accessor :service_id
    attr_accessor :wsdl_path
    attr_reader   :provider

    def initialize
      @collect_polling_timeout = 180
      @collect_polling_delay = 3
      @wsdl_path = WSDL_PATH
      @provider = "bankid"
    end
  end
end
