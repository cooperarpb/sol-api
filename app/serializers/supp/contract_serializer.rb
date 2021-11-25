module Supp
  class ContractSerializer < ActiveModel::Serializer
    include BaseContractSerializer

    attributes :cooperative_title, :bidding_status

    def cooperative_title
      object.user.cooperative.name
    end

    def bidding_status
      object.bidding.status
    end

  end
end
