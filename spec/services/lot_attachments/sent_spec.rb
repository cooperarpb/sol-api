require 'rails_helper'

RSpec.describe LotAttachmentsService::Sent, type: :service do
  let!(:lot_attachment) { create(:lot_attachment) }
  let(:service) { described_class.new(lot_attachment: lot_attachment) }

  describe 'initialize' do
    it { expect(service.lot_attachment).to eq(lot_attachment) }
  end

  describe '.call' do
    subject(:service_call) { service.call }

    context 'when lot_attachment is not valid' do
      before do
        allow_any_instance_of(LotAttachment).to receive(:sent!).and_raise(ActiveRecord::RecordInvalid)
        allow(Notifications::LotAttachments::Sent).to receive(:call).with(lot_attachment)

        service_call
      end

      it { is_expected.to be_falsy }
      it { expect(Notifications::LotAttachments::Sent).not_to have_received(:call) }
    end

    context 'when lot_attachment is valid' do
      before do
        allow_any_instance_of(LotAttachment).to receive(:sent!).and_return(true)
        allow(Notifications::LotAttachments::Sent).to receive(:call).with(lot_attachment)

        service_call
      end

      it { is_expected.to be_truthy }
      it { expect(Notifications::LotAttachments::Sent).to have_received(:call).with(lot_attachment) }
    end
  end
end