RSpec.shared_examples 'services/concerns/clone' do |status|
  let!(:contract_status) { status[:contract_status] }
  let(:service) { described_class.new(contract: contract, contract_params: '') }

  include_examples 'services/concerns/init_contract', contract_status: status&.dig(:init_contract_status)

  let(:api_response) { double('api_response', success?: true) }

  before do
    allow(Blockchain::Contract::Update).to receive(:call!) { api_response }
  end

  subject(:service_call) { described_class.call(contract: contract, contract_params: '') }

  describe '#initialize' do
    it { expect(service.contract).to eq contract }
  end

  describe '.call' do
    let(:worker) { status&.dig(:worker) || Bidding::Minute::AddendumPdfGenerateWorker }
    let(:report_worker) { Bidding::SpreadsheetReportGenerateWorker }

    subject(:service_call) { service.call }

    context 'when success' do
      let!(:api_response) { double('api_response', success?: true) }

      context 'when global' do
        let(:send_notification) { status&.dig(:send_global_notification) }

        before do
          allow(BiddingsService::Cancel).to receive(:call!) { true }
          allow(BiddingsService::Clone).to receive(:call!) { true }

          service_call
        end

        it { expect(contract.send("#{contract_status}?")).to be_truthy }
        it { expect(BiddingsService::Cancel).to have_received(:call!).with(bidding: bidding, send_notification: send_notification) }
        it { expect(BiddingsService::Clone).to have_received(:call!).with(bidding: bidding) }
        it { expect(worker.jobs.size).to eq(1) }
        it { expect(report_worker.jobs.size).to eq(1) }
      end
    end

    context 'when RecordInvalid error' do
      before do
        allow(contract).to receive("#{contract_status}!".to_sym) { raise ActiveRecord::RecordInvalid }

        service_call
      end

      it { expect(contract.send("#{contract_status}?")).to be_falsy }
      it { is_expected.to be_falsy }
    end

    context 'when BC error' do
      before do
        allow(BiddingsService::Cancel).to receive(:call!) { true }
        allow(BiddingsService::Clone).to receive(:call!) { true }
        allow(Blockchain::Contract::Update).to receive(:call!) { raise BlockchainError }
      end

      it { expect(service_call).to be_falsy }
    end
  end
end
