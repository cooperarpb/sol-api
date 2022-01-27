module Search
  module States
    class CitiesController < Search::BaseController
      skip_before_action :auth!
  
      private
  
      def base_resources
        State.find(params[:state_id]).cities.order('name ASC')
      end
    end
  end
end