require 'rails_helper'

RSpec.describe LotQuestionsService::Sent, type: :service do
  let!(:lot_question) { create(:lot_question) }
  let(:service) { described_class.new(lot_question: lot_question) }

  describe 'initialize' do
    it { expect(service.lot_question).to eq(lot_question) }
  end

  describe '.call' do
    subject(:service_call) { service.call }

    context 'when lot_question is not valid' do
      before do
        allow_any_instance_of(LotQuestion).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
        allow(Notifications::LotQuestions::Sent).to receive(:call).with(lot_question)

        service_call
      end

      it { is_expected.to be_falsy }
      it { expect(Notifications::LotQuestions::Sent).not_to have_received(:call) }
    end

    context 'when lot_question is valid' do
      before do
        allow_any_instance_of(LotQuestion).to receive(:save!).and_return(true)
        allow(Notifications::LotQuestions::Sent).to receive(:call).with(lot_question)

        service_call
      end

      it { is_expected.to be_truthy }
      it { expect(Notifications::LotQuestions::Sent).to have_received(:call).with(lot_question) }
    end
  end
end