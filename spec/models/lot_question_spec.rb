require 'rails_helper'

RSpec.describe LotQuestion, type: :model do
  describe 'factory' do
    subject { build(:lot_question) }

    it { is_expected.to be_valid }
  end

  describe 'columns' do
    it { is_expected.to have_db_column(:question).of_type(:text) }
  end

  describe 'associations' do
    it { is_expected.to belong_to :lot }
    it { is_expected.to belong_to :supplier }
    it { is_expected.to have_one :lot_answer }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:question) }
    it { is_expected.to validate_presence_of(:lot) }
    it { is_expected.to validate_presence_of(:supplier) }
  end
end
