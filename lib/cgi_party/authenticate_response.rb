require "cgi_party/response"

module CGIParty
  class AuthenticateResponse < Response
    def autostart_url(return_url)
      "bankid:///?autostarttoken=#{auto_start_token}&redirect=#{return_url}"
    end
  end
end
