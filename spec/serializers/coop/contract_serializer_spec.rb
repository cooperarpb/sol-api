require 'rails_helper'

RSpec.describe Coop::ContractSerializer, type: :serializer do
  describe 'BaseContractsSerializer' do
    include_examples "serializers/concerns/base_contracts_serializer"
  end

  describe 'proposals count attributes' do
    let(:object) { create(:contract, :full_signed_at) }
    let(:bidding) { object.bidding }
    let(:proposals) { bidding.proposals }
    let(:proposals_count) { proposals.not_draft_or_abandoned.count }
    let(:lot_group_item_count) { object.lot_group_items.count }

    subject { format_json(described_class, object) }

    describe 'attributes' do
      it { is_expected.to include 'proposals_count' => proposals_count }
      it { is_expected.to include 'lot_group_item_count' => lot_group_item_count }
    end
  end

end
