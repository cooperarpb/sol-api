require 'rails_helper'

RSpec.describe Notifications::LotAttachments::Sent, type: [:service, :notification] do
  let(:lot_attachment) { create(:lot_attachment) }
  let(:cooperative)   { bidding.cooperative }
  let(:user)          { create(:user, cooperative: cooperative) }
  let!(:lot)          { lot_attachment.lot }
  let!(:bidding)      { lot.bidding }
  let(:extra_args)    { { "bidding_id" => bidding.id, "lot_id" => lot.id} }
  let(:service)       { described_class.new(lot_attachment) }

  describe 'initialization' do
    it { expect(service.lot_attachment).to eq lot_attachment }
  end

  describe 'call' do
    before do
      cooperative.users << user

      service.call
    end

    describe 'user notification' do
      let!(:notification) { user.notifications.last }

      it { expect(notification.receivable).to eq user }
      it { expect(notification.notifiable).to eq lot_attachment }
      it { expect(notification.action).to eq 'lot_attachment.sent' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq [lot.name, bidding.title] }
        it { expect(notification.title_args).to eq [bidding.title] }
        it { expect(notification.extra_args).to eq extra_args }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm', 1
  end
end