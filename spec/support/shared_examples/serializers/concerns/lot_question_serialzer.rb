RSpec.shared_examples "a lot_question_serializer" do
  let(:lot_question) { create :lot_question }

  subject { format_json(described_class, lot_question) }

  describe 'attributes' do
    context 'when lot_question has a lot_question_answer' do
      let(:lot_answer) { create(:lot_answer, lot_question: lot_question) }

      before do
        lot_question.lot_answer = lot_answer
      end

      it { is_expected.to include 'id' => lot_question.id }
      it { is_expected.to include 'question' => lot_question.question }
      it { is_expected.to include 'answer' => lot_answer.answer }
    end

    context 'when lot_question does not have a lot_question_answer' do
      it { is_expected.to include 'id' => lot_question.id }
      it { is_expected.to include 'question' => lot_question.question }
      it { is_expected.to include 'answer' => nil }
    end
  end
end