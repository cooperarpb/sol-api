module Coop
  class BiddingsController < CoopController
    include CrudController

    load_and_authorize_resource

    PERMITTED_PARAMS = [
      :title, :description, :kind, :modality, :status, :deadline, :link, :start_date,
      :closing_date, :covenant_id, :address, :draw_end_days, :classification_id,
      invites_attributes: [
        :id, :provider_id, :_destroy
      ],
      bidding_classifications_attributes: [
        :id, :classification_id, :_destroy
      ],
    ].freeze

    expose :biddings, -> { find_biddings }
    expose :bidding

    before_action :set_paper_trail_whodunnit

    def headquarters
      render json: build_headquarters_address(current_user.cooperative.address)
    end

    private

    def find_biddings
      Bidding.by_cooperative(current_cooperative.id).accessible_by(current_ability)
    end

    def resource
      bidding
    end

    def resources
      biddings
    end

    def bidding_params
      params.require(:bidding).permit(*PERMITTED_PARAMS)
    end

    def build_headquarters_address(main_address)
      full_address = main_address.address == '-' ? '' : main_address.address
      full_address += " #{main_address.number}" if main_address.number != '-' && full_address.present?

      full_address
    end
  end
end
