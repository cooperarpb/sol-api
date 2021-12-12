module Supp
  class Biddings::Lots::LotQuestionsController < SuppController
    include CrudController

    load_and_authorize_resource except: [:create]

    before_action :set_lot_question_supplier_id, only: :create

    PERMITTED_PARAMS = [
      :id, :question, :lot_id
    ].freeze

    expose :bidding
    expose :lot
    expose :lot_question
    expose :lot_questions, -> { find_lot_questions }

    private

    # overrided
    def created?
      LotQuestionsService::Sent.call(lot_question: resource)
    end

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
      LotQuestion.accessible_by(current_ability).by_supplier(current_user).by_lot(lot)
    end

    def lot_question_params
      params.require(:lot_question).permit(*PERMITTED_PARAMS)
    end

    def set_lot_question_supplier_id
      resource.supplier = current_user
    end
  end
end