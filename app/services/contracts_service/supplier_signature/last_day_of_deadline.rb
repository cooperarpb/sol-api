module ContractsService
    class SupplierSignature::LastDayOfDeadline
      include Call::Methods
  
      def main_method
        execute_and_perform
      end
  
      private
  
      def execute_and_perform
        Contract.last_day_of_supplier_signature_deadline.find_each do |contract|
          Notifications::Contracts::SupplierSignature::LastDayOfDeadline.call(contract: contract)
        end
      end
    end
  end