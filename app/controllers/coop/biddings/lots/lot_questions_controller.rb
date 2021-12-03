module Coop
  class Biddings::Lots::LotQuestionsController < CoopController
    include CrudController

    load_and_authorize_resource except: [:update]

    before_action :set_lot_question_user_id, only: :update

    PERMITTED_PARAMS = [
      :id, :answer
    ].freeze

    expose :bidding
    expose :lot
    expose :lot_question
    expose :lot_questions, -> { find_lot_questions }

    private

    def resource
      lot_question
    end

    def resources
      lot_questions
    end

    def default_sort_scope
      resources
    end

    def find_lot_questions
      LotQuestion.accessible_by(current_ability).by_lot(lot)
    end

    def lot_question_params
      params.require(:lot_question).permit(*PERMITTED_PARAMS)
    end

    def set_lot_question_user_id
      resource.user = current_user
    end
  end
end