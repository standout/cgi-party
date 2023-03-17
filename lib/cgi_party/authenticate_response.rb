require "cgi_party/response"

module CGIParty
  class AuthenticateResponse < Response
    def autostart_url(return_url)
      "bankid:///?autostart=#{auto_start_token}&return=#{return_url}"
    end
  end
end
