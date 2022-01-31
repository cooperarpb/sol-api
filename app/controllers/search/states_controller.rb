module Search
  class StatesController < Search::BaseController
    skip_before_action :auth!

    def index
      render json: base_resources, each_serializer: Supp::StateSerializer
    end

    private

    def base_resources
      State.all.order('name ASC')
    end
  end
end