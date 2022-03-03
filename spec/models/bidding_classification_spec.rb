require 'rails_helper'

RSpec.describe BiddingClassification, type: :model do
  describe 'factory' do
    subject(:factory) { build(:bidding) }

    it { is_expected.to be_valid }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:bidding) }
    it { is_expected.to belong_to(:classification) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :bidding }
    it { is_expected.to validate_presence_of :classification }
  end
end
