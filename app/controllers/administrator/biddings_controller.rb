module Administrator
  class BiddingsController < AdminController
    include CrudController

    load_and_authorize_resource

    expose :bidding
    expose :biddings, -> { find_biddings }

    private

    def resource
      bidding
    end

    def resources
      biddings
    end

    def find_biddings
      Bidding.accessible_by(current_ability)
    end

    def default_sort_scope
      return searched_resources if params[:status].blank?

      resources.where(status: params[:status])
    end
  end
end
