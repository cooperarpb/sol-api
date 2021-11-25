require 'rails_helper'

RSpec.describe Contract::SupplierSignature::ExpiredDeadlineWorker, type: :worker do
  let(:service) { ContractsService::SupplierSignature::ExpiredDeadline }
  let(:service_method) { :call }

  include_examples 'workers/perform_without_params'
end
