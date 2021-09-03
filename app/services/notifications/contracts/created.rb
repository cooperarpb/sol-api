module Notifications
  class Contracts::Created < Contracts::Base

    private

    def body_args
      [Contract::SUPPLIER_SIGNATURE_DEADLINE, contract.title]
    end

    def receivables
      [admin, suppliers]
    end
  end
end
