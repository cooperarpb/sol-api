require 'rails_helper'

RSpec.describe Supp::StateSerializer, type: :serializer do
  let(:object) { create :state }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'text' => object.name }
  end
end