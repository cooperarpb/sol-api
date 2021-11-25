module ContractsService
  class Proposals::UnsignedBySupplier < Proposals::Base
    private

    def change_status_fail_and_retry
      return false unless contract.waiting_signature?

      super
    end

    def change_contract_status!
      contract.unsigned_by_supplier!
    end

    def notify
      Notifications::Contracts::UnsignedBySupplier.call(contract: contract)
    end
  end
end
