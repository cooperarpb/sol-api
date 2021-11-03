module ContractsService
  class Clone::TotalInexecution < Clone::Base
    private

    def execute_and_perform
      if change_status_cancel_and_clone
        generate_minute_addendum
        generate_inexecution_reason_addendum
      end

      change_status_cancel_and_clone
    end

    def change_status_cancel_and_clone
      @change_status_cancel_and_clone ||= begin
        return false unless contract.signed?

        super
      end
    end

    def change_contract_status!
      contract.total_inexecution!
    end

    def update_contract!
      contract.update!(contract_params) if contract_params&.present?
    end

    def notify
      Notifications::Contracts::TotalInexecution.call(contract: contract)
    end

    def generate_inexecution_reason_addendum
      Bidding::Minute::AddendumInexecutionReasonPdfGenerateWorker.perform_async(contract.id)
    end
  end
end
