module Supp
  class Biddings::Lots::LotAttachmentsController < SuppController
    include CrudController

    load_and_authorize_resource except: [:create]

    before_action :set_lot_attachment_supplier_id, only: :create

    PERMITTED_PARAMS = [
      :id, :lot_id,
      attachment_attributes: [
        :id, :file, :_destroy
      ]
    ].freeze

    expose :bidding
    expose :lot
    expose :lot_attachment
    expose :lot_attachments, -> { find_lot_attachments }

    def send_lot_attachment
      if LotAttachmentsService::Sent.call(lot_attachment: resource)
        render json: resource, status: :ok
      else
        render json: resource.errors, status: :unprocessable_entity
      end
    end

    private

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
      LotAttachment.accessible_by(current_ability)
                           .by_supplier(current_user)
                           .by_lot(lot)
    end

    def lot_attachment_params
      params.require(:lot_attachment).permit(*PERMITTED_PARAMS)
    end

    def set_lot_attachment_supplier_id
      resource.supplier = current_user
    end
  end
end
