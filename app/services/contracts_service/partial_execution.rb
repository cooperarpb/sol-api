module ContractsService
  class PartialExecution
    include TransactionMethods
    include Call::Methods

    def main_method
      generate_inexecution_reason_addendum if completed
      completed
    end

    private

    def completed
      @completed ||= begin
        return false unless contract.signed?

        execute_or_rollback do
          contract.partial_execution!
          update!
          recalculate_available_quantity!
          update_contract_blockchain!
          notify
        end
      end
    end

    def update!
      contract.update!(contract_params)
    end

    def update_contract_blockchain!
      Blockchain::Contract::Update.call!(contract: contract)
    end

    def recalculate_available_quantity!
      RecalculateQuantityService.call!(covenant: contract.bidding.covenant)
    end

    def notify
      Notifications::Contracts::PartialExecution.call(contract: contract)
    end

    def generate_inexecution_reason_addendum
      Bidding::Minute::AddendumInexecutionReasonPdfGenerateWorker.perform_async(contract.id)
    end
  end
end
