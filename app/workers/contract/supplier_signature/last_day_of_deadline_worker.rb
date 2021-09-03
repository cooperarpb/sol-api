class Contract::SupplierSignature::LastDayOfDeadlineWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5
  
  def perform
    ContractsService::SupplierSignature::LastDayOfDeadline.call
  end
end
