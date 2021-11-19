require File.expand_path('../environment', __FILE__)

# Cooperative API Integration
coop_cron_syntax_frequency = ::Integration::Cooperative::Configuration.first_or_initialize.schedule
if coop_cron_syntax_frequency.present?
  every coop_cron_syntax_frequency do
    runner "Import::CooperativeWorker.perform_async"
  end
end

# Covenant API Integration
covenant_cron_syntax_frequency = ::Integration::Covenant::Configuration.first_or_initialize.schedule
if covenant_cron_syntax_frequency.present?
  every covenant_cron_syntax_frequency do
    runner "Import::CovenantWorker.perform_async"
  end
end

# Item API Integration
item_cron_syntax_frequency = ::Integration::Item::Configuration.first_or_initialize.schedule
if item_cron_syntax_frequency.present?
  every item_cron_syntax_frequency do
    runner "Import::ItemWorker.perform_async"
  end
end


# Devido à implementação do item 17 foi removida a execução do worker que verificava
# se existiam contratos não assinados há mais de 5 dias. O script iria interferir na
# verificação automática dos contratos expirados, uma vez que, o prazo máximo de
# assinatura do contrato pelo fornecedor é de 5 dias.
# Refuse old contracts
# every 30.minutes, roles: [:app] do
#   runner "Contract::SystemRefuseWorker.perform_async"
# end

# TODO: Alterar schedule após testes em QA
# every 5.minutes, roles: [:app] do
every 1.day, at: '02:00 am', roles: [:app] do
  # Notifica aos fornecedores que o prazo de assinatura do contrato definido pela 
  # constante Contract::SUPPLIER_SIGNATURE_DEADLINE está próximo 
  runner "Contract::SupplierSignature::CloseToDeadlineWorker.perform_async"
end

# TODO: Alterar schedule após testes em QA
# every 5.minutes, roles: [:app] do
every 1.day, at: '03:00 am', roles: [:app] do
  # Notifica aos fornecedores que é o último dia do prazo de assinatura do contrato
  # definido pela constante Contract::SUPPLIER_SIGNATURE_DEADLINE
  runner "Contract::SupplierSignature::LastDayOfDeadlineWorker.perform_async"
end

# TODO: Alterar schedule após testes em QA
# every 5.minutes, roles: [:app] do
every 1.day, at: '04:00 am', roles: [:app] do
  # Caso o prazo de assinatura do contrato expirar, verifica se há outra proposta 
  # de outro fornecedor e "reinicia o processo da licitação" ou encerra a licitação 
  # e cria uma nova como rascunho
  runner "Contract::SupplierSignature::ExpiredDeadlineWorker.perform_async"
end

# Status changes
every 1.day, at: '08:00 am', roles: [:app] do
  runner "Bidding::ApprovedToOngoingWorker.perform_async"
end

every 1.day, at: '12:00 pm', roles: [:app] do
  runner "Bidding::OngoingToUnderReviewWorker.perform_async"
  runner "Bidding::DrawToUnderReviewWorker.perform_async"
end
