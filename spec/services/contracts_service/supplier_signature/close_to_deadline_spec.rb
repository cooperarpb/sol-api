require 'rails_helper'

RSpec.describe ContractsService::SupplierSignature::CloseToDeadline, type: :service do
  let(:service) { ContractsService::SupplierSignature::CloseToDeadline }
  
  describe 'execute_and_perform' do
    before do
      contract
      allow(Notifications::Contracts::SupplierSignature::CloseToDeadline).to receive(:call).with(contract: contract)
  
      service.call
    end

    context 'when there are close to deadline contracts (2 days left) to be signed' do
      let(:contract) do
        create(:contract, supplier: nil, created_at: (Contract::SUPPLIER_SIGNATURE_DEADLINE - 2).days.ago)
      end

      it { expect(Notifications::Contracts::SupplierSignature::CloseToDeadline).to have_received(:call).with(contract: contract) }
    end

    context 'when there are no close to deadline contract' do
      let(:contract) do
        create(:contract, supplier: nil, created_at: Date.today)
      end

      it { expect(Notifications::Contracts::SupplierSignature::CloseToDeadline).not_to have_received(:call).with(contract: contract) }
    end
  end

end