require 'rails_helper'

RSpec.describe Contract::SupplierSignature::LastDayOfDeadlineWorker, type: :worker do
  let(:service) { ContractsService::SupplierSignature::LastDayOfDeadline }
  let(:service_method) { :call }

  include_examples 'workers/perform_without_params'
end
