require 'rails_helper'

RSpec.describe Administrator::LotAttachmentSerializer, type: :serializer do
  let!(:attachment) { create(:attachment, attachable: lot_attachment) }
  let(:lot_attachment) { create :lot_attachment }

  subject { format_json(described_class, lot_attachment) }

  describe 'attributes' do
    it { is_expected.to include 'id' => lot_attachment.id }
    it { is_expected.to include 'supplier_name' => lot_attachment.supplier.name }
    it { is_expected.to include 'lot_name' => lot_attachment.lot.name }
    it { is_expected.to include 'status' => lot_attachment.status }
    it { is_expected.to include 'attachment_file' => attachment.file.serializable_hash }
    it { is_expected.to include 'attachment_filename' => lot_attachment.attachment.file.file.filename }
  end
end
