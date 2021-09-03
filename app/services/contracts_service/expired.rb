module ContractsService
  class Expired < ContractsService::Base

    private

    def contract_status!
      contract.total_inexecution!
    end

    def notify
      Notifications::Contracts::Created.call(contract: contract)
    end
  end
end
