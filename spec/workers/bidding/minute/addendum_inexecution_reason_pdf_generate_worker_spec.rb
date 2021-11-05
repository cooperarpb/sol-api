require 'rails_helper'

RSpec.describe Bidding::Minute::AddendumInexecutionReasonPdfGenerateWorker, type: :worker do
  let(:contract) { create(:contract) }
  let(:service) { BiddingsService::Minute::AddendumInexecutionReasonPdfGenerate }
  let(:service_method) { :call! }
  let(:params) { [contract.id] }

  include_examples 'workers/perform_with_params'
end
