module ContractsService
  class Proposals::UnsignedBySupplier < Proposals::Base
    def main_method
      generate_addendum_unsigned_by_supplier_pdf if change_status_fail_and_retry

      change_status_fail_and_retry
    end

    private

    def change_status_fail_and_retry
      @change_status_fail_and_retry ||= begin
        return false unless contract.waiting_signature?

        super
      end
    end

    def change_contract_status!
      contract.unsigned_by_supplier!
    end

    def notify
      Notifications::Contracts::UnsignedBySupplier.call(contract: contract)
    end

    def generate_addendum_unsigned_by_supplier_pdf
      Bidding::Minute::AddendumUnsignedBySupplierPdfGenerateWorker.perform_async(contract.id)
    end
  end
end
