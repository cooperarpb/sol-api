module Coop
  class ContractSerializer < ActiveModel::Serializer
    include BaseContractSerializer

    attributes :proposals_count, :lot_group_item_count

    def proposals_count
      proposals.count
    end

    def lot_group_item_count
      object.lot_group_items.count
    end

    private

    def proposals
      bidding.proposals_not_draft_or_abandoned
    end

    def global?
      bidding.global?
    end

    def bidding
      object.bidding
    end
    
  end
end
