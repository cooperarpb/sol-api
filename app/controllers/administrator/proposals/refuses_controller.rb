module Administrator
  class Proposals::RefusesController < AdminController
    include BaseRefusesController

    load_and_authorize_resource :proposal, parent: false

    expose :proposal

    before_action :set_paper_trail_whodunnit

    private

    def refused?
      ProposalService::Admin::Refuse.call(proposal: proposal)
    end

    def bidding
      proposal.bidding
    end
  end
end
