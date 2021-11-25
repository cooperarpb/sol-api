# Serviço responsável por verificar se o tempo de assinatura do contrato 
# pelo fornecedor expirou, ou seja, ultrapassou o prazo definido pela constante
# Contract::SUPPLIER_SIGNATURE_DEADLINE.
module ContractsService
  class SupplierSignature::ExpiredDeadline
    include Call::Methods

    def main_method
      execute_and_perform
    end

    private

    def execute_and_perform
      Contract.expired_supplier_signature_deadline.find_each do |contract|
        # Obtém a última proposta do contrato do lote vinculado ao contrato
        contract_lot_proposal = contract&.proposal&.lot_proposals&.last

        next unless contract_lot_proposal

        next unless accepted_lot?(contract_lot_proposal)

        other_sent_lot_proposals = other_sent_lot_proposals_from_same_lot_proposal(contract_lot_proposal)

        next unless other_sent_lot_proposals

        if another_lot_proposal?(other_sent_lot_proposals)
          # Executa o mesmo mecanismo da Inexecução Total indicando a próxima proposta a ser validada
          ContractsService::Proposals::UnsignedBySupplier.call(contract: contract)
        else
          # Executa o mesmo mecanismo da Inexecução Total encerrando a licitação e criando 
          # uma nova licitação como rascunho
          ContractsService::Clone::UnsignedBySupplier.call(contract: contract)
        end
      end
    end

    # Encontra os demais lot_proposals do lote pertencente à proposta vencedora
    def other_sent_lot_proposals_from_same_lot_proposal(lot_proposal)
      # TODO: Refatorar
      lot_proposal&.lot&.lot_proposals&.includes(:proposal)&.where(proposals: { status: :sent })
    end

    def another_lot_proposal?(lot_proposals)
      lot_proposals.count > 0
    end

    def accepted_lot?(lot_proposal)
      lot_proposal&.lot&.accepted?
    end
  end
end