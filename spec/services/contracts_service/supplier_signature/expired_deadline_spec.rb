require 'rails_helper'

RSpec.describe ContractsService::SupplierSignature::ExpiredDeadline, type: :service do
  let(:bidding) { create(:bidding, status: :finnished) }
  let(:lot_1) { create(:lot, bidding: bidding, status: :accepted) }
  let(:lot_2) { create(:lot, bidding: bidding, status: :accepted) }
  let(:proposal_1) { build(:proposal, bidding: bidding, status: :accepted, build_lot_proposal: false) }
  let(:proposal_2) { build(:proposal, bidding: bidding, status: :sent, build_lot_proposal: false) }
  let(:lot_proposal_1) { create(:lot_proposal, lot: lot_1, proposal: proposal_1) }
  let(:lot_proposal_2) { create(:lot_proposal, lot: lot_1, proposal: proposal_2) }
  let(:expired_contract) do 
    create(:contract, status: :waiting_signature, proposal: proposal_1, 
            created_at: Contract::SUPPLIER_SIGNATURE_DEADLINE.days.ago) 
  end
  let(:service) { ContractsService::SupplierSignature::ExpiredDeadline }
  
  describe 'execute_and_perform' do
    context 'when there is another lot_proposal that belongs to the same bidding lot' do
      context 'and it is a lot_proposal with status "sent"' do
        before do
          proposal_1.lot_proposals << lot_proposal_1
          proposal_2.lot_proposals << lot_proposal_2
          proposal_1.save
          proposal_2.save
          expired_contract
  
          allow(ContractsService::Proposals::UnsignedBySupplier).to receive(:call).with(contract: expired_contract)
          allow(ContractsService::Clone::UnsignedBySupplier).to receive(:call).with(contract: expired_contract)
          
          service.call
        end
  
        it { expect(ContractsService::Proposals::UnsignedBySupplier).to have_received(:call).with(contract: expired_contract).once }
        it { expect(ContractsService::Clone::UnsignedBySupplier).not_to have_received(:call).with(contract: expired_contract) }
      end

      context 'and it is not a lot_proposal with status "sent"' do
        before do
          proposal_2.status = :failure
          proposal_1.lot_proposals << lot_proposal_1
          proposal_2.lot_proposals << lot_proposal_2
          proposal_1.save
          proposal_2.save
          expired_contract
  
          allow(ContractsService::Proposals::UnsignedBySupplier).to receive(:call).with(contract: expired_contract)
          allow(ContractsService::Clone::UnsignedBySupplier).to receive(:call).with(contract: expired_contract)
          
          service.call
        end
  
        it { expect(ContractsService::Proposals::UnsignedBySupplier).not_to have_received(:call).with(contract: expired_contract) }
        it { expect(ContractsService::Clone::UnsignedBySupplier).to have_received(:call).with(contract: expired_contract).once }
      end  
    end

    context 'when there is not another lot_proposal that belongs to the same bidding lot' do    
      before do
        proposal_1.lot_proposals << lot_proposal_1
        proposal_1.save
        expired_contract

        allow(ContractsService::Proposals::UnsignedBySupplier).to receive(:call).with(contract: expired_contract)
        allow(ContractsService::Clone::UnsignedBySupplier).to receive(:call).with(contract: expired_contract)

        service.call
      end

      it { expect(ContractsService::Proposals::UnsignedBySupplier).not_to have_received(:call).with(contract: expired_contract) }
      it { expect(ContractsService::Clone::UnsignedBySupplier).to have_received(:call).with(contract: expired_contract).once }
    end

    context 'when a contract does not have a proposal for some reason' do
      before do
        expired_contract.update_column(:proposal_id, nil)

        allow(ContractsService::Proposals::UnsignedBySupplier).to receive(:call).with(contract: expired_contract)
        allow(ContractsService::Clone::UnsignedBySupplier).to receive(:call).with(contract: expired_contract)

        service.call
      end

      it { expect(ContractsService::Proposals::UnsignedBySupplier).not_to have_received(:call).with(contract: expired_contract) }
      it { expect(ContractsService::Clone::UnsignedBySupplier).not_to have_received(:call).with(contract: expired_contract) }
    end

    context 'when last contract proposal has a lot with status different from accepted' do
      let(:lot_1) { create(:lot, bidding: bidding, status: :canceled) }

      before do
        proposal_1.lot_proposals << lot_proposal_1
        proposal_1.save
        expired_contract

        allow(ContractsService::Proposals::UnsignedBySupplier).to receive(:call).with(contract: expired_contract)
        allow(ContractsService::Clone::UnsignedBySupplier).to receive(:call).with(contract: expired_contract)

        service.call
      end

      it { expect(ContractsService::Proposals::UnsignedBySupplier).not_to have_received(:call).with(contract: expired_contract) }
      it { expect(ContractsService::Clone::UnsignedBySupplier).not_to have_received(:call).with(contract: expired_contract) }
    end
  end
end