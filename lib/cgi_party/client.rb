require "savon"


module CGIParty
  class Client
    attr_reader :savon_client, :collect_responses, :polling_started_at

    def initialize
      @savon_client = Savon.client(savon_opts)
      @collect_responses = []
    end

    def poll_authentication(ssn, &block)
      response = authenticate(ssn)
      sleep(9)
      @polling_started_at = Time.now
      protective_poll_loop(response.order_ref, response.transaction_id, &block)
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

    def protective_poll_loop(order_ref, transaction_id)
      loop do
        break if timeout_polling?
        collect_response = collect(order_ref, transaction_id)
        @collect_responses << collect_response
        yield(collect_response.progress_status)
        return collect_response if collect_response.authentication_finished?
        sleep(3)
      end
    end

    def timeout_polling?
      polling_duration >= 180
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
