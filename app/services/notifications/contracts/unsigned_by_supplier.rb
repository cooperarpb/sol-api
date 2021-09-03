module Notifications
  class Contracts::UnsignedBySupplier < Contracts::Base

    private

    def body_args
      [contract.title, bidding.title]
    end

    def receivables
      [admin, user]
    end
  end
end
