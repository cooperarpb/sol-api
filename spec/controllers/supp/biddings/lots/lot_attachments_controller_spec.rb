require 'rails_helper'

RSpec.describe Supp::Biddings::Lots::LotAttachmentsController, type: :controller do
  let(:serializer) { Supp::LotAttachmentSerializer }
  let(:bidding) { create(:bidding, status: :ongoing) }
  let(:lot) { create(:lot) }
  let(:user) { create(:supplier) }
  let(:lot_attachment) { create(:lot_attachment, lot: lot, supplier: user) }

  before do
    oauth_token_sign_in user

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

      describe 'exposes' do
        let(:stub_lot_attachments) { LotAttachment.all }

        before do
          allow(LotAttachment).to receive(:by_supplier).with(user) { stub_lot_attachments }
          allow(stub_lot_attachments).to receive(:by_lot).with(lot) { LotAttachment.all }

          get_index
        end

        it { expect(LotAttachment).to have_received(:by_supplier).with(user) }
        it { expect(stub_lot_attachments).to have_received(:by_lot).with(lot) }
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

  describe '#create' do
    let(:lot_attachment) { build(:lot_attachment, lot: lot, supplier: user) }
    let(:params) { { bidding_id: bidding.id, lot_id: lot.id, lot_attachment: lot_attachment.attributes } }

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    context 'when valid params it saves lot_attachment on database' do
      it { expect{ post_create }.to change{ LotAttachment.count }.by(1) }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before do
          post_create
        end

        it { expect(response).to have_http_status :created }
        it { expect(json['lot_attachment']).to be_present }
      end

      context 'when not created' do
        before do
          allow(controller.lot_attachment).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#send_lot_attachment' do
    let(:params) { { bidding_id: bidding.id, lot_id: lot.id, id: lot_attachment.id } }

    subject(:post_send_lot_attachment) { post :send_lot_attachment, params: params, xhr: true }

    context 'when lot_attachment is updated with success' do
      before do
        allow(LotAttachmentsService::Sent).to receive(:call).with(lot_attachment: lot_attachment).and_return(true)
      end

      it { is_expected.to have_http_status :ok }
    end

    context 'when lot_attachment is updated with error' do
      before do
        allow(LotAttachmentsService::Sent).to receive(:call).with(lot_attachment: lot_attachment).and_return(false)
      end

      it { is_expected.to have_http_status :unprocessable_entity }
    end
  end
end