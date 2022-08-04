module Coop
  class Biddings::Lots::LotAttachmentsController < CoopController
    include CrudController

    load_and_authorize_resource

    expose :bidding
    expose :lot
    expose :lot_attachment
    expose :lot_attachments, -> { find_lot_attachments }

    def request_lot_attachment
      if supplier.present?
        Notifications::LotAttachments::Request.call(params[:notification_message], lot, supplier)
      
        render status: :ok
      else
        render status: :unprocessable_entity
      end
    end

    private

    def supplier
      @supplier ||= LotProposal.active_and_orderly_with(lot, Proposal::IGNORED_PROPOSAL_STATUSES_FOR_LOT_ATTACHMENTS)&.first&.supplier
    end

    def resource
      lot_attachment
    end

    def resources
      lot_attachments
    end

    def default_sort_scope
      resources
    end

    def find_lot_attachments
      LotAttachment.accessible_by(current_ability).by_lot(lot)
    end
  end
end
