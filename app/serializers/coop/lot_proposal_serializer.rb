module Coop
  class LotProposalSerializer < ActiveModel::Serializer
    attributes :id, :proposal_id, :status, :bidding_id, :bidding_title,
                :price_total, :delivery_price, :current, :lot, :provider, 
                :suppliers

    has_many :lot_group_item_lot_proposals, serializer: Supp::LotGroupItemLotProposalSerializer

    def lot
      Coop::LotSerializer.new(object.lot)
    end

    def proposal
      object.proposal
    end

    def proposal_id
      proposal.id
    end

    def current
      proposal.triage?
    end

    def provider
      proposal.provider.as_json
    end

    def suppliers
      proposal.provider.suppliers.as_json
    end

    def bidding_id
      object.lot.bidding_id
    end

    def bidding_title
      object.lot.bidding.title
    end
  end
end
