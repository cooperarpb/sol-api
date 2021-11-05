module Coop::Contract
  class TotalInexecution::CloneBiddingsController < CoopController
    include CrudController

    PERMITTED_PARAMS = [
      :id, :inexecution_reason
    ].freeze

    load_and_authorize_resource :contract, parent: false

    expose :contract

    before_action :set_paper_trail_whodunnit

    private

    def resource
      contract
    end

    def updated?
      ContractsService::Clone::TotalInexecution.call(contract: contract, contract_params: contract_params)
    end

    def contract_params
      params.require(:contract).permit(*PERMITTED_PARAMS)
    end
  end
end
