module ContractsService
  class Proposals::TotalInexecution < Proposals::Base
    private

    def main_method
      generate_inexecution_reason_addendum if change_status_fail_and_retry
      change_status_fail_and_retry
    end

    def change_status_fail_and_retry
      @change_status_fail_and_retry ||= begin
        return false unless contract.signed?

        super
      end
    end

    def change_contract_status!
      contract.total_inexecution!
    end

    def update_contract!
      contract.update!(contract_params) if contract_params.present?
    end

    def notify
      Notifications::Contracts::TotalInexecution.call(contract: contract)
    end

    def generate_inexecution_reason_addendum
      Bidding::Minute::AddendumInexecutionReasonPdfGenerateWorker.perform_async(contract.id)
    end
  end
end
