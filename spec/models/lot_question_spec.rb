require 'rails_helper'

RSpec.describe LotQuestion, type: :model do
  describe 'factory' do
    subject { build(:lot_question) }

    it { is_expected.to be_valid }
  end

  describe 'columns' do
    it { is_expected.to have_db_column(:question).of_type(:text) }
    it { is_expected.to have_db_column(:answer).of_type(:text) }
  end

  describe 'associations' do
    it { is_expected.to belong_to :lot }
    it { is_expected.to belong_to :supplier }
    it { is_expected.to belong_to(:user).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:question) }
    it { is_expected.to validate_presence_of(:lot) }
    it { is_expected.to validate_presence_of(:supplier) }
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'lot_questions.created_at' }
    it { expect(described_class.default_sort_direction).to eq :desc }
  end

  describe 'methods' do
    describe 'by_supplier' do
      let(:supplier) { create(:supplier) }
      let(:supplier_lot_question) { create(:lot_question, supplier: supplier) }
      let(:another_lot_question) { create(:lot_question) }

      before do
        supplier_lot_question
        another_lot_question
      end

      it { expect(LotQuestion.by_supplier(supplier)).to match_array([supplier_lot_question]) }
    end

    describe 'by_lot' do
      let(:lot) { create(:lot) }
      let(:lot_lot_question) { create(:lot_question, lot: lot) }
      let(:another_lot_question) { create(:lot_question) }

      before do
        lot_lot_question
        another_lot_question
      end

      it { expect(LotQuestion.by_lot(lot)).to match_array([lot_lot_question]) }
    end
  end
end
