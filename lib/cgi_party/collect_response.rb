require "cgi_party/response"

module CGIParty
  class CollectResponse < Response
    def authentication_finished?
      !authentication_ongoing?
    end

    def authentication_ongoing?
      ongoing_statuses.include? progress_status
    end

    private

    def ongoing_statuses
      %w(OUTSTANDING_TRANSACTION USER_SIGN)
    end
  end
end
