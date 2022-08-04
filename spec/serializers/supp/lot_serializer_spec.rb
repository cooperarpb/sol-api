require 'rails_helper'

RSpec.describe Supp::LotSerializer, type: :serializer do
  it_behaves_like 'a lot_serializer'

  describe 'allow_lot_attachment_action' do
    subject(:serializer) { described_class.new(lot, scope: supplier) }

    let(:bidding_status)       { :ongoing }
    let(:bidding_closing_date) { Date.today - 1.day }
    let(:lot)                  { create(:lot, bidding: bidding) }
    let(:supplier)             { create(:supplier) }
    let(:bidding)              { create(:bidding, status: bidding_status, closing_date: bidding_closing_date) }

    before do
      bidding.lots << lot
    end

    context 'when bidding does not have under_review status' do
      it { expect(serializer.allow_lot_attachment_action).to be_falsey }
    end

    context 'when current supplier does not equal lot`s winner' do
      let(:bidding_status)   { :under_review }
      let(:another_supplier) { create(:supplier) }
      let(:proposal)         { create(:proposal, status: :triage) }
      let!(:lot_proposal)    { create(:lot_proposal, lot: lot, supplier: another_supplier, proposal: proposal) }

      it { expect(serializer.allow_lot_attachment_action).to be_falsey }
    end

    context 'when there is a cooperative request`s notification' do
      let(:bidding_status)          { :under_review }
      let(:proposal)                { create(:proposal, status: :triage) }
      let!(:lot_proposal)           { create(:lot_proposal, lot: lot, supplier: supplier, proposal: proposal) }
      let(:notification_created_at) { Date.today }
      let!(:notification) do 
        create(:notification, notifiable: lot, action: 'lot_attachment.request', created_at: notification_created_at)
      end

      context 'and today is greater than notification`s created_at date plus 2 days' do
        let(:notification_created_at) { Date.today - 3.days }

        it { expect(serializer.allow_lot_attachment_action).to be_falsey }
      end

      context 'and today is less or equal than notification`s created_at date plus 2 days' do
        it { expect(serializer.allow_lot_attachment_action).to be_truthy }
      end
    end

    context 'when there is no cooperative request`s notification' do
      let(:bidding_status) { :under_review }
      let(:proposal)       { create(:proposal, status: :triage) }
      let!(:lot_proposal)  { create(:lot_proposal, lot: lot, supplier: supplier, proposal: proposal) }

      context 'and today is greater than bidding`s closing_date plus 5 days' do
        let(:bidding_closing_date) { Date.today - 6.days }

        it { expect(serializer.allow_lot_attachment_action).to be_falsey }
      end

      context 'and today is less or equal than bidding`s closing_date date plus 5 days' do
        it { expect(serializer.allow_lot_attachment_action).to be_truthy }
      end
    end
  end
end
