module Supp
  class LotSerializer < ActiveModel::Serializer
    include LotSerializable

    attributes :allow_lot_attachment_action

    def allow_lot_attachment_action
      return false unless bidding.under_review?
      return false unless current_supplier == supplier

      if last_coop_lot_attachment_notification_to_lot.present?
        return Date.today <= last_coop_lot_attachment_notification_to_lot.created_at + 2.days
      end

      Date.today <= object.bidding.closing_date + 5.days
    end

    private

    def current_supplier
      @current_supplier ||= @instance_options&.dig(:scope)
    end

    def last_coop_lot_attachment_notification_to_lot
      @last_coop_lot_attachment_notification_to_lot ||= Notification.where(notifiable: object, action: 'lot_attachment.request').last
    end

    def ignored_proposal_statuses
      Proposal::IGNORED_PROPOSAL_STATUSES_FOR_LOT_ATTACHMENTS
    end

    def supplier
      @supplier ||= LotProposal.active_and_orderly_with(object, ignored_proposal_statuses)&.first&.supplier
    end
  end
end
