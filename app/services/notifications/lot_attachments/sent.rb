module Notifications
  class LotAttachments::Sent < Base

    attr_accessor :lot_attachment

    def initialize(lot_attachment)
      @lot_attachment = lot_attachment
    end

    def call
      notify
    end

    def self.call(lot_attachment)
      new(lot_attachment).call
    end

    private
    
    def extra_args
      { bidding_id: bidding.id, lot_id: lot.id }
    end

    def notifiable
      lot_attachment
    end

    def title_args
      [bidding.title]
    end

    def body_args
      [lot.name, bidding.title]
    end

    def bidding
      @bidding ||= lot.bidding
    end

    def lot
      @lot ||= lot_attachment.lot
    end
    
    def cooperative
      @cooperative ||= bidding.cooperative
    end

    def users
      @users ||= cooperative.users
    end

    def receivables
      [users]
    end
  end
end