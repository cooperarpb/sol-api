require 'rails_helper'

RSpec.describe Supp::BiddingSerializer, type: :serializer do
  it_behaves_like 'a bidding_serializer'

  describe 'extra attributes' do
    describe 'show_new_button_question' do
      subject { format_json(described_class, object) }
  
      let(:closing_date) { Date.today }
      let(:object) { create :bidding, closing_date: closing_date }
  
      context 'when close to closing_date' do
        it { is_expected.to include 'show_new_button_question' => false }
      end
  
      context 'when not close to closing_date' do
        let(:closing_date) { Date.today + 2.days}

        it { is_expected.to include 'show_new_button_question' => true }
      end
    end
  end


end
