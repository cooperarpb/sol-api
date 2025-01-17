require 'rails_helper'

RSpec.describe ContractsService::Clone::TotalInexecution, type: :service do
  let(:permitted_params) do
    [:id, :inexecution_reason]
  end

  let(:params) do
    { contract: { id: contract.id, inexecution_reason: 'Motivo' } }
  end

  let(:contract_params) do
    ActionController::Parameters.
      new(params).require(:contract).permit(permitted_params)
  end
  
  before do
    allow(Notifications::Contracts::TotalInexecution).
      to receive(:call).with(contract: contract).and_return(true)
    allow(Blockchain::Contract::Update).to receive(:call!).and_return(true)
  end

  subject(:service_call) { described_class.call(contract: contract, contract_params: contract_params) }

  context 'when the bidding type is global' do
    include_examples 'services/concerns/clone', contract_status: :total_inexecution,
                                                send_global_notification: true
  end

  context 'when the bidding type are lots' do
    describe '.call' do
      let(:worker) { Bidding::Minute::AddendumPdfGenerateWorker }
      let(:report_worker) { Bidding::SpreadsheetReportGenerateWorker }

      include_examples 'services/concerns/init_contract_lot'

      context 'when success' do
        let(:proposal) { contract.proposal }

        before do
          allow(LotsService::Cancel).to receive(:call!).and_return(true)
          allow(LotsService::Clone).to receive(:call!).and_return(true)

          service_call
        end

        it { is_expected.to be_truthy }
        it { expect(contract.total_inexecution?).to be_truthy }
        it do
          expect(LotsService::Cancel).
            to have_received(:call!).with(proposal: proposal)
        end
        it do
          expect(LotsService::Clone).
            to have_received(:call!).with(proposal: proposal)
        end
        it do
          expect(Notifications::Contracts::TotalInexecution).
            to have_received(:call).with(contract: contract)
        end
        it { expect(worker.jobs.size).to eq(1) }
        it { expect(report_worker.jobs.size).to eq(1) }
      end

      context 'when RecordInvalid error' do
        before do
          allow(LotsService::Cancel).
            to receive(:call!).and_raise(ActiveRecord::RecordInvalid)

          service_call
        end

        it { expect(contract.reload.total_inexecution?).to be_falsy }
        it { is_expected.to be_falsy }
        it do
          expect(Notifications::Contracts::TotalInexecution).
            to_not have_received(:call).with(contract: contract)
        end
        it { expect(worker.jobs.size).to eq(0) }
        it { expect(report_worker.jobs.size).to eq(0) }
      end

      context 'when BC error' do
        before do
          allow(LotsService::Cancel).to receive(:call!).and_return(true)
          allow(LotsService::Clone).to receive(:call!).and_return(true)
          allow(Blockchain::Contract::Update).
            to receive(:call!).and_raise(BlockchainError)

          service_call
        end

        it { expect(contract.reload.total_inexecution?).to be_falsy }
        it { expect(service_call).to be_falsy }
        it do
          expect(Notifications::Contracts::TotalInexecution).
            to_not have_received(:call).with(contract: contract)
        end
        it { expect(worker.jobs.size).to eq(0) }
        it { expect(report_worker.jobs.size).to eq(0) }
      end
    end
  end

  context 'when contract is not signed' do
    let(:user) { create(:user) }
    let(:bidding) { create(:bidding) }
    let(:proposal) { create(:proposal, bidding: bidding) }
    let(:contract) do
      create(:contract, proposal: proposal, user: user, user_signed_at: DateTime.current)
    end

    it { is_expected.to be_falsy }
  end

  context 'when contract_params is present' do
    include_examples 'services/concerns/init_contract'

    subject(:service_call) { described_class.call(contract: contract, contract_params: contract_params) }

    before do
      allow(Bidding::Minute::AddendumInexecutionReasonPdfGenerateWorker).to receive(:perform_async).with(contract.id)
      service_call

      contract.reload
    end

    it { expect(contract.inexecution_reason).to eq('Motivo') }
    it { expect(Bidding::Minute::AddendumInexecutionReasonPdfGenerateWorker).to have_received(:perform_async).with(contract.id) }
  end
end
