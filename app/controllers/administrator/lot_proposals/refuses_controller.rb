module Administrator
  class LotProposals::RefusesController < AdminController
    include BaseRefusesController

    load_and_authorize_resource :lot_proposal, parent: false

    expose :lot_proposal

    before_action :set_paper_trail_whodunnit

    private

    def refused?
      ProposalService::Admin::LotProposal::Refuse.call(lot_proposal: lot_proposal)
    end

    def bidding
      lot_proposal.proposal.bidding
    end
  end
end
