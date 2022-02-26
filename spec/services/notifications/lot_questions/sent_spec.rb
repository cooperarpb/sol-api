require 'rails_helper'

RSpec.describe Notifications::LotQuestions::Sent, type: [:service, :notification] do
  let(:lot_question)  { create(:lot_question) }
  let(:cooperative)   { bidding.cooperative }
  let(:admin)         { bidding.admin }
  let(:user)          { create(:user, cooperative: cooperative) }
  let!(:lot)          { lot_question.lot }
  let!(:bidding)      { lot.bidding }
  let(:extra_args)    { { "bidding_id" => bidding.id, "lot_id" => lot.id} }
  let(:service)       { described_class.new(lot_question) }

  describe 'initialization' do
    it { expect(service.lot_question).to eq lot_question }
  end

  describe 'call' do
    before do
      cooperative.users << user

      service.call
    end

    describe 'user notification' do
      let!(:notification) { user.notifications.last }

      it { expect(notification.receivable).to eq user }
      it { expect(notification.notifiable).to eq lot_question }
      it { expect(notification.action).to eq 'lot_question.sent' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq [lot.name, bidding.title] }
        it { expect(notification.title_args).to eq [bidding.title] }
        it { expect(notification.extra_args).to eq extra_args }
      end
    end

    describe 'user notification' do
      let!(:notification) { admin.notifications.last }

      it { expect(notification.receivable).to eq admin }
      it { expect(notification.notifiable).to eq lot_question }
      it { expect(notification.action).to eq 'lot_question.sent' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq [lot.name, bidding.title] }
        it { expect(notification.title_args).to eq [bidding.title] }
        it { expect(notification.extra_args).to eq extra_args }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm', 2
  end
end