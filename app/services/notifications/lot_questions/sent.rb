module Notifications
  class LotQuestions::Sent < LotQuestions::Base

    private
    
    def cooperative
      @cooperative ||= bidding.cooperative
    end

    def users
      @users ||= cooperative.users
    end

    def receivables
      [admin, users]
    end
  end
end
