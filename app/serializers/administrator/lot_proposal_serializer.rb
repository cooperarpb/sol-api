module Administrator
  class LotProposalSerializer < ActiveModel::Serializer
    include CurrentEventProposable

    attributes :lot, :suppliers, :lot_attachments

    has_many :lot_group_item_lot_proposals, serializer: Administrator::LotGroupItemLotProposalSerializer

    def lot
      Administrator::LotSerializer.new(object.lot)
    end

    def proposal
      object.proposal
    end

    def bidding_id
      object.lot.bidding_id
    end

    def bidding_title
      object.lot.bidding.title
    end

    def suppliers
      object.proposal.provider.suppliers.as_json
    end

    def lot_attachments
      ActiveModelSerializers::SerializableResource.new(
        object.lot.lot_attachments.sent.where(supplier: object.supplier),
        each_serializer: Administrator::LotAttachmentSerializer
      )
    end

    private

    def event_resource
      proposal
    end
  end
end
