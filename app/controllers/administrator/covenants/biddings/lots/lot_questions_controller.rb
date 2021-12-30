module Administrator
  class Covenants::Biddings::Lots::LotQuestionsController < AdminController
    include CrudController

    load_and_authorize_resource :lot_question, parent: false

    expose :bidding
    expose :lot
    expose :lot_questions, -> { find_lot_questions }
    expose :lot_question

    private

    def resources
      lot_questions
    end

    def resource
      lot_question
    end

    def default_sort_scope
      resources
    end

    def find_lot_questions
      LotQuestion.accessible_by(current_ability).by_lot(lot)
    end
  end
end