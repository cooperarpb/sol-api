require 'rails_helper'

RSpec.describe LotAnswer, type: :model do
  describe 'factory' do
    subject { build(:lot_answer) }

    it { is_expected.to be_valid }
  end

  describe 'columns' do
    it { is_expected.to have_db_column(:answer).of_type(:text) }
  end

  describe 'associations' do
    it { is_expected.to belong_to :lot_question }
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:answer) }
    it { is_expected.to validate_presence_of(:lot_question) }
    it { is_expected.to validate_presence_of(:user) }
  end
end
