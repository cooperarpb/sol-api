module Notifications
  class LotQuestions::Answered < LotQuestions::Base

    private

    def supplier
      @supplier ||= lot_question.supplier
    end

    def receivables
      [admin, supplier]
    end
  end
end
