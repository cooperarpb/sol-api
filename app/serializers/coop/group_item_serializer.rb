module Coop
  class GroupItemSerializer < ActiveModel::Serializer
    include GroupItemSerializable

    attribute :covenant_draft_biddings_in_use, if: :covenant

    def covenant
      scope&.dig(:covenant)
    end

    def covenant_draft_biddings_in_use
      Bidding.draft
             .includes(:lot_group_items)
             .where(lot_group_items: { group_item_id: object }, covenant: covenant)
             .pluck(:title)
             .to_sentence
    end
  end
end
