module ContractsService
  class Clone::UnsignedBySupplier < Clone::Base
    private

    def change_status_cancel_and_clone
      @change_status_cancel_and_clone ||= begin
        return false unless contract.waiting_signature?

        super
      end
    end

    def change_contract_status!
      contract.unsigned_by_supplier!
    end

    def cancel_and_clone_bidding!
      # xxx: Does not send bidding`s cancel notification because the request is
      # not realized by user
      BiddingsService::Cancel.call!(bidding: bidding, send_notification: false)
      BiddingsService::Clone.call!(bidding: bidding)
    end

    def notify
      Notifications::Contracts::UnsignedBySupplier.call(contract: contract)
    end
  end
end
