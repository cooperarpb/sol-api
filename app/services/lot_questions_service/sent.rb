module LotQuestionsService
  class Sent
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
        lot_question.save!
        lot_question.reload
        notify
      end
    end

    def notify
      Notifications::LotQuestions::Sent.call(lot_question)
    end
  end
end