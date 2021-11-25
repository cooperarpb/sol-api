# frozen_string_literal: true

module Notifications
  module Contracts
    module SupplierSignature
      class LastDayOfDeadline < Contracts::Base

        private

        def body_args
          contract.title
        end

        def receivables
          supplier
        end

        def supplier
          # Recupera o fornecedor vinculado à proposta do lote do contrato.
          # Isso foi necessário, pois a notificação é enviada no momento em que
          # não há assinatura do fornecedor no contrato, logo não há supplier
          # vinculado ao contract.
          @supplier ||= contract&.proposal&.lot_proposals&.last&.supplier
        end
      end
    end
  end
end
