require "cgi_party/request"

module CGIParty
  class CollectRequest
    include CGIParty::Request
    attr_reader :order_reference, :transaction_id

    def initialize(savon_client, order_reference, transaction_id = nil)
      @order_reference = order_reference
      @transaction_id = transaction_id
      @savon_client = savon_client
    end

    private

    def message_hash
      {
        display_name: CGIParty.config.display_name,
        policy: CGIParty.config.service_id,
        transaction_id: @transaction_id,
        order_ref: @order_reference
      }
    end
  end
end
