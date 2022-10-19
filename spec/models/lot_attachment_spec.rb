require 'rails_helper'

RSpec.describe LotAttachment, type: :model do
  describe 'factory' do
    subject { build(:lot_attachment) }

    it { is_expected.to be_valid }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:lot) }
    it { is_expected.to belong_to(:supplier) }
    it { is_expected.to have_one(:attachment).dependent(:destroy) }
  end

  describe 'enums' do
    describe 'status' do
      it { is_expected.to define_enum_for(:status).with_values({ pending: 0, sent: 1 }) }
    end
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'lot_attachments.created_at' }
    it { expect(described_class.default_sort_direction).to eq :desc }
  end

  describe 'nested_attributes' do
    it { is_expected.to accept_nested_attributes_for(:attachment).allow_destroy(true) }
  end

  describe 'methods' do
    describe 'by_supplier' do
      let(:supplier) { create(:supplier) }
      let(:supplier_lot_attachment) { create(:lot_attachment, supplier: supplier) }
      let(:another_lot_attachment) { create(:lot_attachment) }

      before do
        supplier_lot_attachment
        another_lot_attachment
      end

      it { expect(LotAttachment.by_supplier(supplier)).to match_array([supplier_lot_attachment]) }
    end

    describe 'by_lot' do
      let(:lot) { create(:lot) }
      let(:lot_lot_attachment) { create(:lot_attachment, lot: lot) }
      let(:another_lot_attachment) { create(:lot_attachment) }

      before do
        lot_lot_attachment
        another_lot_attachment
      end

      it { expect(LotAttachment.by_lot(lot)).to match_array([lot_lot_attachment]) }
    end
  end
end
