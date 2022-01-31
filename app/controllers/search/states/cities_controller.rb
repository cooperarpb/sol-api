module Search
  module States
    class CitiesController < Search::BaseController
      skip_before_action :auth!
  
      private
  
      def base_resources
        City.where(state_id: params[:state_id]).order('name ASC')
      end
    end
  end
end