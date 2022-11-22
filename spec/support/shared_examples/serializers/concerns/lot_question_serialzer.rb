RSpec.shared_examples "a lot_question_serializer" do
  let(:answer) { 'My answer' }
  let(:lot_question) { create :lot_question, answer: answer }

  subject { format_json(described_class, lot_question) }

  describe 'attributes' do
    context 'when lot_question has an answer' do
      it { is_expected.to include 'id' => lot_question.id }
      it { is_expected.to include 'question' => lot_question.question }
      it { is_expected.to include 'answer' => lot_question.answer }
    end

    context 'when lot_question does not have an answer' do
      let(:answer) { nil }

      it { is_expected.to include 'id' => lot_question.id }
      it { is_expected.to include 'question' => lot_question.question }
      it { is_expected.to include 'answer' => nil }
    end
  end
end