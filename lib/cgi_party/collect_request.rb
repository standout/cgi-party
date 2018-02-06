require "cgi_party/collect_response"
require "cgi_party/request"

module CGIParty
  class CollectRequest < CGIParty::Request
    attr_reader :order_reference, :transaction_id

    def initialize(savon_client, order_reference, transaction_id = nil, options: {})
      super(savon_client, options)
      @order_reference = order_reference
      @transaction_id = transaction_id
    end

    private

    def serialize_data(data)
      CGIParty::CollectResponse.new(data)
    end

    def available_options
      %i[display_name service_id]
    end

    def message_hash
      {
        display_name: @options[:display_name],
        policy: @options[:service_id],
        transaction_id: @transaction_id,
        order_ref: @order_reference
      }
    end
  end
end
