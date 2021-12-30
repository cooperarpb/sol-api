module Notifications
  class LotQuestions::Base < Base
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

    def bidding
      @bidding ||= lot.bidding
    end

    def lot
      @lot ||= lot_question.lot
    end

    def admin
      @admin ||= bidding.admin
    end
  end
end