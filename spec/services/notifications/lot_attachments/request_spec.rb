require 'rails_helper'

RSpec.describe Notifications::LotAttachments::Request, type: [:service, :notification] do
  let(:lot_attachment) { create(:lot_attachment) }
  let(:supplier)       { create(:supplier) }
  let!(:lot)           { lot_attachment.lot }
  let!(:bidding)       { lot.bidding }
  let(:extra_args)     { { "bidding_id" => bidding.id, "lot_id" => lot.id} }
  let(:service)        { described_class.new(notification_message, lot, supplier) }
  let(:notification_message) { "Message" }

  describe 'initialization' do
    it { expect(service.notification_message).to eq notification_message }
    it { expect(service.lot).to eq lot }
    it { expect(service.supplier).to eq supplier }
  end

  describe 'call' do
    before do
      service.call
    end

    describe 'supplier notification' do
      let!(:notification) { supplier.notifications.last }

      it { expect(notification.receivable).to eq supplier }
      it { expect(notification.notifiable).to eq lot }
      it { expect(notification.action).to eq 'lot_attachment.request' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq [lot.name, bidding.title, notification_message] }
        it { expect(notification.title_args).to eq [bidding.title] }
        it { expect(notification.extra_args).to eq extra_args }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm', 1
  end
end