require 'rails_helper'

RSpec.describe Contract::SupplierSignature::CloseToDeadlineWorker, type: :worker do
  let(:service) { ContractsService::SupplierSignature::CloseToDeadline }
  let(:service_method) { :call }

  include_examples 'workers/perform_without_params'
end
