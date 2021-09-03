module ContractsService
  class SupplierSignature::CloseToDeadline
    include Call::Methods

    def main_method
      execute_and_perform
    end

    private

    def execute_and_perform
      Contract.close_to_supplier_signature_deadline.find_each do |contract|
        Notifications::Contracts::SupplierSignature::CloseToDeadline.call(contract: contract)
      end
    end
  end
end