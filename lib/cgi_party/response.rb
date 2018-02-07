module CGIParty
  class Response
    attr_reader :received_at

    def initialize(source_data)
      @source_data = source_data
      @received_at = Time.now
    end

    def method_missing(method_name, *args, &block)
      return fetch_value(method_name) if key_present?(method_name)
      super
    end

    def respond_to_missing?(method_name, include_private = false)
      key_present?(method_name) || super
    end

    private

    def fetch_value(key)
      @source_data.values.first.fetch(key.to_sym, nil)
    end

    def key_present?(key)
      @source_data.values.first.key?(key)
    end
  end
end
