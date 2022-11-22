require 'rails_helper'

RSpec.describe ContractsService::Proposals::UnsignedBySupplier, type: :service do
  before do
    allow(Notifications::Contracts::UnsignedBySupplier).
      to receive(:call).with(contract: contract).and_return(true)

    allow(Blockchain::Contract::Update).to receive(:call!).and_return(true)
  end

  subject(:service_call) { described_class.call(contract: contract) }

  context 'when the bidding type is global' do
    include_examples 'services/concerns/proposal', contract_status: :unsigned_by_supplier,
                                                   init_contract_status: :waiting_signature
  end

  context 'when the bidding have only one proposal' do
    include_examples 'services/concerns/init_contract', contract_status: :waiting_signature

    context 'when success' do
      before do
        allow(BiddingsService::Proposals::Retry).
          to receive(:call!).and_return(true)

        service_call
      end

      it { expect(BiddingsService::Proposals::Retry).not_to have_received(:call!) }
    end
  end

  context 'when the bidding type are lots' do
    describe '.call' do
      include_examples 'services/concerns/init_contract_lot', contract_status: :waiting_signature

      let(:contract_bidding) { contract.bidding }

      context 'when success' do
        let(:contract_proposal) { contract.proposal }

        before do
          allow(BiddingsService::Proposals::Retry).
            to receive(:call!).and_return(true)

          service_call
        end

        it { expect(contract.unsigned_by_supplier?).to be_truthy }
        it { expect(proposal_c_lot_1.reload.failure?).to be_truthy }
        it { expect(contract_bidding.reopen_reason_contract).to be_instance_of(Contract) }
        it do
          expect(BiddingsService::Proposals::Retry).
            to have_received(:call!).
            with(bidding: contract_bidding, proposal: contract_proposal)
        end
        it do
          expect(Notifications::Contracts::UnsignedBySupplier).
            to have_received(:call).with(contract: contract)
        end
      end

      context 'when RecordInvalid error' do
        before do
          allow(contract).
            to receive(:unsigned_by_supplier!).
            and_raise(ActiveRecord::RecordInvalid)

          service_call
        end

        it { expect(contract.reload.unsigned_by_supplier?).to be_falsy }
        it { expect(service_call).to be_falsy }
        it { expect(contract_bidding.reopen_reason_contract).to be_nil }
        it do
          expect(Notifications::Contracts::UnsignedBySupplier).
            to_not have_received(:call).with(contract: contract)
        end
      end

      context 'when BC error' do
        before do
          allow(Blockchain::Contract::Update).
            to receive(:call!).with(contract: contract).
            and_raise(BlockchainError)
        end

        it { expect(contract.reload.unsigned_by_supplier?).to be_falsy }
        it { expect(service_call).to be_falsy }
        it { expect(contract_bidding.reopen_reason_contract).to be_nil }
        it do
          expect(Notifications::Contracts::UnsignedBySupplier).
            to_not have_received(:call).with(contract: contract)
        end
      end
    end
  end

  context 'when contract is not waiting signature' do
    let(:user) { create(:user) }
    let(:bidding) { create(:bidding) }
    let(:proposal) { create(:proposal, bidding: bidding) }
    let(:contract) do
      create(:contract, proposal: proposal, status: :signed, user: user, user_signed_at: DateTime.current)
    end

    it { is_expected.to be_falsy }
  end
end
