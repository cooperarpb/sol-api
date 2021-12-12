require 'rails_helper'

RSpec.describe LotQuestionsService::Answered, type: :service do
  let!(:lot_question) { create(:lot_question) }
  let(:lot_question_attributes) { lot_question.attributes }
  let(:service) { described_class.new(lot_question: lot_question, lot_question_attributes: lot_question_attributes) }

  describe 'initialize' do
    it { expect(service.lot_question).to eq(lot_question) }
    it { expect(service.lot_question_attributes).to eq(lot_question_attributes) }
  end

  describe '.call' do
    subject(:service_call) { service.call }

    context 'when lot_question is not valid' do
      before do
        allow_any_instance_of(LotQuestion).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
        allow(Notifications::LotQuestions::Answered).to receive(:call).with(lot_question)

        service_call
      end

      it { is_expected.to be_falsy }
      it { expect(Notifications::LotQuestions::Answered).not_to have_received(:call) }
    end

    context 'when lot_question is valid' do
      before do
        allow_any_instance_of(LotQuestion).to receive(:update!).and_return(true)
        allow(Notifications::LotQuestions::Answered).to receive(:call).with(lot_question)

        service_call
      end

      it { is_expected.to be_truthy }
      it { expect(Notifications::LotQuestions::Answered).to have_received(:call).with(lot_question) }
    end
  end
end