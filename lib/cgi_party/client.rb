require "savon"


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

    def authenticate(ssn)
      CGIParty::AuthenticateRequest.new(@savon_client, ssn).execute
    end

    def collect(order_reference, transaction_id)
      CGIParty::CollectRequest.new(@savon_client, order_reference, transaction_id).execute
    end

    private

    def timeout_polling?
      polling_duration >= CGIParty.config.collect_polling_timeout
    end

    def savon_opts
      {
        namespace: CGIParty::WSDL_NAMESPACE,
        namespace_identifier: :v1,
        wsdl: CGIParty.config.wsdl_path,
        env_namespace: :soapenv,
        ssl_verify_mode: :none
      }
    end
  end
end
