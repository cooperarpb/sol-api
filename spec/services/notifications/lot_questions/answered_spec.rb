require 'rails_helper'

RSpec.describe Notifications::LotQuestions::Answered, type: [:service, :notification] do
  let(:lot_question)  { create(:lot_question) }
  let(:cooperative)   { bidding.covenant.cooperative }
  let(:supplier)      { lot_question.supplier }
  let!(:lot)          { lot_question.lot }
  let!(:bidding)      { lot.bidding }
  let(:extra_args)    { { "bidding_id" => bidding.id, "lot_id" => lot.id} }
  let(:service)       { described_class.new(lot_question) }

  describe 'initialization' do
    it { expect(service.lot_question).to eq lot_question }
  end

  describe 'call' do
    before { service.call }

    describe 'notification' do
      let!(:notification) { Notification.last }

      it { expect(notification.receivable).to eq supplier }
      it { expect(notification.notifiable).to eq lot_question }
      it { expect(notification.action).to eq 'lot_question.answered' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq [lot.name, bidding.title] }
        it { expect(notification.title_args).to eq [bidding.title] }
        it { expect(notification.extra_args).to eq extra_args }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm'
  end
end