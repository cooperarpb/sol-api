require 'rails_helper'

RSpec.describe Administrator::LotSerializer, type: :serializer do
  it_behaves_like 'a lot_serializer'

  describe 'extra attributes' do
    describe 'estimated_cost_total' do
      let(:object) { create :lot }

      subject { format_json(described_class, object) }

      it { is_expected.to include 'estimated_cost_total' => object.estimated_cost_total }
    end
  end
end
