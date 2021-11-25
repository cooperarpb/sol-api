class Contract::SupplierSignature::ExpiredDeadlineWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5
  
  def perform
    ContractsService::SupplierSignature::ExpiredDeadline.call
  end
end
