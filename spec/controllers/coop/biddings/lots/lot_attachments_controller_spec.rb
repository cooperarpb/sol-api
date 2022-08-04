require 'rails_helper'

RSpec.describe Coop::Biddings::Lots::LotAttachmentsController, type: :controller do
  let(:serializer) { Coop::LotAttachmentSerializer }
  let(:bidding) { create(:bidding, status: :under_review) }
  let(:lot) { create(:lot, bidding: bidding) }
  let(:cooperative) { user.cooperative}
  let(:covenant) { bidding.covenant }
  let(:user) { create(:user) }
  let(:supplier) { create(:supplier) }
  let(:lot_attachment) { create(:lot_attachment, lot: lot, supplier: supplier) }

  before do
    oauth_token_sign_in user

    covenant.update_columns(cooperative_id: cooperative.id)
    bidding.lots << lot
  end

  describe '#index' do
    let(:params) { { bidding_id: bidding.id, lot_id: lot.id } }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { LotAttachment }
    end

    describe 'helpers' do
      let!(:params) do
        { bidding_id: bidding.id, lot_id: lot.id, page: 2 }
      end

      let(:lot_attachments) { LotAttachment.all }

      before do
        allow(lot_attachments).to receive(:sorted) { lot_attachments }
        allow(lot_attachments).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:lot_attachments) { lot_attachments }

        get_index
      end

      it { expect(lot_attachments).to have_received(:sorted).with('lot_attachments.created_at', :desc) }
      it { expect(lot_attachments).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      describe 'http_status' do
        before { get_index }

        it { expect(response).to have_http_status :ok }
      end

      describe 'JSON' do
        let(:lot_attachments) { LotAttachment.all }

        before { get_index }

        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { lot_attachments.map { |lot_attachment| format_json(serializer, lot_attachment) } }

        it { expect(json).to match_array expected_json }
      end
    end
  end

  describe '#request_lot_attachment' do
    let(:params) { { bidding_id: bidding.id, lot_id: lot.id, id: lot_attachment.id, notification_message: "Message" } }
    let(:supplier) { create(:supplier) }
    let(:lot_proposal) { create(:lot_proposal, lot: lot, supplier: supplier) }

    subject(:post_request_lot_attachment) { post :request_lot_attachment, params: params, xhr: true }
    
    context 'when supplier exists' do
      before do
        allow(LotProposal).to receive(:active_and_orderly_with).with(lot, Proposal::IGNORED_PROPOSAL_STATUSES_FOR_LOT_ATTACHMENTS) { [lot_proposal]}
        allow(Notifications::LotAttachments::Request).to receive(:call).with(params[:notification_message], lot, supplier)

        post_request_lot_attachment
      end

      it { is_expected.to have_http_status :ok }
      it { expect(Notifications::LotAttachments::Request).to have_received(:call) }
    end

    context 'when supplier does not exist' do
      context 'when supplier exists' do
        before do
          allow(Notifications::LotAttachments::Request).to receive(:call).with(params[:notification_message], lot, supplier)

          post_request_lot_attachment
        end

        it { is_expected.to have_http_status :unprocessable_entity }
        it { expect(Notifications::LotAttachments::Request).not_to have_received(:call) }
      end
    end

  end
end