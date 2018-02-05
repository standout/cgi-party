module CGIParty
  class Response
    attr_reader :received_at

    def initialize(source_data)
      @source_data = source_data
      @received_at = Time.now
    end

    def method_missing(method_name, *args, &block)
      fetch_value(method_name) || super
    end

    def respond_to_missing?(method_name, include_private = false)
      fetch_value(method_name) || super
    end

    private

    def fetch_value(key)
      @source_data.values.first.fetch(key.to_sym, nil)
    end
  end
end
