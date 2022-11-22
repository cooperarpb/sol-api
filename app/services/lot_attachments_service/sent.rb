module LotAttachmentsService
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
        lot_attachment.sent!
        lot_attachment.reload
        notify
      end
    end

    def notify
      Notifications::LotAttachments::Sent.call(lot_attachment)
    end
  end
end