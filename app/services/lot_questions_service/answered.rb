module LotQuestionsService
  class Answered
    include TransactionMethods
    include Call::WithExceptionsMethods

    def main_method
      execute_and_perform
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def execute_and_perform
      execute_or_rollback do
        lot_question.update!(lot_question_attributes)
        lot_question.reload
        notify
      end
    end

    def notify
      Notifications::LotQuestions::Answered.call(lot_question)
    end
  end
end