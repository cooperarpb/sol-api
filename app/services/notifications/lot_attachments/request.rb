module Notifications
  class LotAttachments::Request < Base

    attr_accessor :notification_message, :lot, :supplier

    def initialize(notification_message, lot, supplier)
      @notification_message = notification_message
      @lot = lot
      @supplier = supplier
    end

    def call
      notify
    end

    def self.call(notification_message, lot, supplier)
      new(notification_message, lot, supplier).call
    end

    private
    
    def extra_args
      { bidding_id: bidding.id, lot_id: lot.id }
    end

    def notifiable
      lot
    end

    def title_args
      [bidding.title]
    end

    def body_args
      [lot.name, bidding.title, notification_message]
    end

    def bidding
      @bidding ||= lot.bidding
    end

    def ignored_proposal_statuses
      Proposal::IGNORED_PROPOSAL_STATUSES_FOR_LOT_ATTACHMENTS
    end

    def receivables
      [@supplier]
    end
  end
end