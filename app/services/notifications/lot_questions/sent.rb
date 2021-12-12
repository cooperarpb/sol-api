module Notifications
  class LotQuestions::Sent < Base

    attr_accessor :lot_question

    def initialize(lot_question)
      @lot_question = lot_question
    end

    def call
      notify
    end

    def self.call(lot_question)
      new(lot_question).call
    end

    private

    def extra_args
      { bidding_id: bidding.id, lot_id: lot.id }
    end

    def notifiable
      lot_question
    end

    def title_args
      [bidding.title]
    end

    def body_args
      [lot.name, bidding.title]
    end

    def cooperative
      @cooperative ||= bidding.cooperative
    end

    def users
      @users ||= cooperative.users
    end

    def bidding
      @bidding ||= lot.bidding
    end

    def lot
      @lot ||= lot_question.lot
    end

    def receivables
      users
    end
  end
end
