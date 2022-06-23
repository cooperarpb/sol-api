require 'rails_helper'

RSpec.describe Supp::ProviderSerializer, type: :serializer do
  it_behaves_like 'a provider_serializer'

  describe 'attributes' do
    let(:object) { create :provider }
    let(:supplier) { create(:supplier) }

    subject { format_json(described_class, object, scope: supplier) }

    describe 'current_supplier' do
      it { is_expected.to include 'current_supplier' }
    end
  end
end
