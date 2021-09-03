class Contract::SupplierSignature::CloseToDeadlineWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5
  
  def perform
    ContractsService::SupplierSignature::CloseToDeadline.call
  end
end
