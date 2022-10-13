require 'rails_helper'

RSpec.describe Bidding::Minute::AddendumUnsignedBySupplierPdfGenerateWorker, type: :worker do
  let(:contract) { create(:contract) }
  let(:service) { BiddingsService::Minute::AddendumUnsignedBySupplierPdfGenerate }
  let(:service_method) { :call! }
  let(:params) { [contract.id] }

  include_examples 'workers/perform_with_params'
end
