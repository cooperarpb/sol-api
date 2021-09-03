require 'rails_helper'

RSpec.describe ContractsService::SupplierSignature::LastDayOfDeadline, type: :service do
  let(:service) { ContractsService::SupplierSignature::LastDayOfDeadline }
  
  describe 'execute_and_perform' do
    before do
      contract
      allow(Notifications::Contracts::SupplierSignature::LastDayOfDeadline).to receive(:call).with(contract: contract)
  
      service.call
    end

    context 'when there are contracts on the last day of the signature' do
      let(:contract) do
        create(:contract, supplier: nil, created_at: (Contract::SUPPLIER_SIGNATURE_DEADLINE - 1).days.ago)
      end

      it { expect(Notifications::Contracts::SupplierSignature::LastDayOfDeadline).to have_received(:call).with(contract: contract) }
    end

    context 'when there are no contract on the last day of the signature' do
      let(:contract) do
        create(:contract, supplier: nil, created_at: Date.today)
      end

      it { expect(Notifications::Contracts::SupplierSignature::LastDayOfDeadline).not_to have_received(:call).with(contract: contract) }
    end
  end

end