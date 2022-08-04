require 'rails_helper'

RSpec.describe Coop::GroupItemSerializer, type: :serializer do
  it_behaves_like 'a group_item_serializer'

  describe 'extra attributes' do
    describe '#covenant_draft_biddings_in_use' do
      let(:object) { create :group_item }

      context 'when covenant scope param is present' do
        let(:draft_bidding)    { create(:bidding, status: :draft) }
        let(:another_bidding)  { create(:bidding, status: :waiting, covenant: covenant) }
        let(:covenant)         { draft_bidding.covenant }
        let(:lot)              { create(:lot, bidding: draft_bidding) }
        let!(:lot_group_item)  { create(:lot_group_item, lot: lot, group_item: object) }

        let(:another_lot)              { create(:lot, bidding: another_bidding) }
        let!(:another_lot_group_item)  { create(:lot_group_item, lot: another_lot, group_item: object) }

        subject { format_json(described_class, object, scope: { covenant: covenant }) }

        it { expect(subject.keys).to include 'covenant_draft_biddings_in_use' }
        it { expect(subject['covenant_draft_biddings_in_use'].count).to eq(1) }
      end

      context 'when covenant scope is not present' do
        subject { format_json(described_class, object) }

        it { expect(subject.keys).not_to include 'covenant_draft_biddings_in_use' }
      end
    end
  end
end
