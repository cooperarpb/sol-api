module Search
  class StatesController < Search::BaseController
    skip_before_action :auth!

    LIMIT = 26.freeze

    private

    def base_resources
      State
    end
  end
end