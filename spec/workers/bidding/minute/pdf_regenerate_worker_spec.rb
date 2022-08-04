require 'rails_helper'

RSpec.describe Bidding::Minute::PdfRegenerateWorker, type: :worker do
  let(:bidding) { create(:bidding) }
  let(:service) { BiddingsService::Minute::PdfRegenerate }
  let(:service_method) { :call! }
  let(:params) { [bidding.id] }

  include_examples 'workers/perform_with_params'
end
