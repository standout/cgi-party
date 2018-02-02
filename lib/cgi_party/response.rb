module CGIParty
  class Response
    def initialize(source_data)
      @source_data = source_data
    end

    def method_missing(method_name, *args, &block)
      fetch_value(method_name) || super
    end

    def respond_to_missing?(method_name, include_private = false)
      fetch_value(method_name).present? || super
    end

    private

    def fetch_value(key)
      @source_data.values.first.fetch(key.to_sym, {})
    end
  end
end
