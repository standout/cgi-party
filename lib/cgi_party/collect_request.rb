require "cgi_party/collect_response"
require "cgi_party/request"

module CGIParty
  class CollectRequest < CGIParty::Request
    attr_reader :order_reference, :transaction_id

    def initialize(savon_client, order_reference,
                   transaction_id = nil, options: {})
      super(savon_client, options)
      @order_reference = order_reference
      @transaction_id = transaction_id
    end

    private

    def serialize_data(data)
      CGIParty::CollectResponse.new(data)
    end

    def available_options
      %i[display_name service_id provider]
    end

    def message_hash
      {
        policy: @options[:service_id],
        provider: @options[:provider],
        rp_display_name: @options[:display_name],
        transaction_id: @transaction_id,
        order_ref: @order_reference
      }
    end
  end
end
