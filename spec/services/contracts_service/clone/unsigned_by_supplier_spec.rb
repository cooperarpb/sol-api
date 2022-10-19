require 'rails_helper'

RSpec.describe ContractsService::Clone::UnsignedBySupplier, type: :service do
  before do
    allow(Notifications::Contracts::UnsignedBySupplier).
      to receive(:call).with(contract: contract).and_return(true)
    allow(Blockchain::Contract::Update).to receive(:call!).and_return(true)
  end

  subject(:service_call) { described_class.call(contract: contract) }

  context 'when the bidding type is global' do
    include_examples 'services/concerns/clone', contract_status: :unsigned_by_supplier,
                                                init_contract_status: :waiting_signature,
                                                send_global_notification: false,
                                                worker: Bidding::Minute::AddendumUnsignedBySupplierPdfGenerateWorker
  end

  context 'when the bidding type are lots' do
    describe '.call' do
      let(:worker) { Bidding::Minute::AddendumUnsignedBySupplierPdfGenerateWorker }

      include_examples 'services/concerns/init_contract_lot', contract_status: :waiting_signature

      context 'when success' do
        let(:proposal) { contract.proposal }

        before do
          allow(LotsService::Cancel).to receive(:call!).and_return(true)
          allow(LotsService::Clone).to receive(:call!).and_return(true)

          service_call
        end

        it { is_expected.to be_truthy }
        it { expect(contract.unsigned_by_supplier?).to be_truthy }
        it do
          expect(LotsService::Cancel).
            to have_received(:call!).with(proposal: proposal)
        end
        it do
          expect(LotsService::Clone).
            to have_received(:call!).with(proposal: proposal)
        end
        it do
          expect(Notifications::Contracts::UnsignedBySupplier).
            to have_received(:call).with(contract: contract)
        end
        it { expect(worker.jobs.size).to eq(1) }
      end

      context 'when RecordInvalid error' do
        before do
          allow(LotsService::Cancel).
            to receive(:call!).and_raise(ActiveRecord::RecordInvalid)

          service_call
        end

        it { expect(contract.reload.unsigned_by_supplier?).to be_falsy }
        it { is_expected.to be_falsy }
        it do
          expect(Notifications::Contracts::UnsignedBySupplier).
            to_not have_received(:call).with(contract: contract)
        end
        it { expect(worker.jobs.size).to eq(0) }
      end

      context 'when BC error' do
        before do
          allow(LotsService::Cancel).to receive(:call!).and_return(true)
          allow(LotsService::Clone).to receive(:call!).and_return(true)
          allow(Blockchain::Contract::Update).
            to receive(:call!).and_raise(BlockchainError)

          service_call
        end

        it { expect(contract.reload.unsigned_by_supplier?).to be_falsy }
        it { expect(service_call).to be_falsy }
        it do
          expect(Notifications::Contracts::UnsignedBySupplier).
            to_not have_received(:call).with(contract: contract)
        end
        it { expect(worker.jobs.size).to eq(0) }
      end
    end
  end

  context 'when contract is not waiting signature' do
    let(:user) { create(:user) }
    let(:bidding) { create(:bidding) }
    let(:proposal) { create(:proposal, bidding: bidding) }
    let(:contract) do
      create(:contract, :full_signed_at, status: :signed, proposal: proposal, user: user, user_signed_at: DateTime.current)
    end

    it { is_expected.to be_falsy }
  end
end
