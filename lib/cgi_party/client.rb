require "savon"
require "rqrcode"

module CGIParty
  class Client
    attr_reader :savon_client, :collect_responses, :polling_started_at

    def initialize
      @savon_client = Savon.client(savon_opts)
    end

    def poll_collect(order_ref, transaction_id = nil)
      @polling_started_at = Time.now

      loop do
        collect_response = collect(order_ref, transaction_id)
        return collect_response if timeout_polling?

        yield(collect_response)
        return collect_response if collect_response.authentication_finished?

        sleep(CGIParty.config.collect_polling_delay)
      end
    end

    def polling_duration
      Time.now - @polling_started_at
    end

    def authenticate(ip_address, options: {})
      CGIParty::AuthenticateRequest.new(@savon_client,
                                        ip_address,
                                        options: options)
                                   .execute
    end

    def generate_qr(start_token:, start_secret:, seconds:)
      RQRCode::QRCode.new(qr_auth_code(start_token, start_secret, seconds))
    end

    def collect(order_reference, transaction_id, options: {})
      CGIParty::CollectRequest.new(@savon_client,
                                   order_reference,
                                   transaction_id,
                                   options: options)
                              .execute
    end

    private

    def timeout_polling?
      polling_duration >= CGIParty.config.collect_polling_timeout
    end

    def qr_auth_code(start_token, start_secret, seconds)
      auth_code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("SHA256"),
                                          start_secret,
                                          seconds.to_s)

      "bankid.#{start_token}.#{seconds}.#{auth_code}"
    end

    def savon_opts
      {
        soap_version: 2,
        namespace: CGIParty::WSDL_NAMESPACE,
        namespace_identifier: :v2,
        wsdl: CGIParty.config.wsdl_path,
        env_namespace: :soapenv,
        ssl_verify_mode: :none
      }
    end
  end
end
