require 'rails_helper'

RSpec.describe InexecutionReasonDocument, type: :model do
  subject(:inexecution_reason_document) { build(:inexecution_reason_document) }

  context 'factories' do
    it { is_expected.to be_valid }
  end

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:biddings) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :file }
  end
end
