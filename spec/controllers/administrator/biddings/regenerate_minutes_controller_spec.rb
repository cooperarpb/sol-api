require 'rails_helper'

RSpec.describe Administrator::Biddings::RegenerateMinutesController, type: :controller do
  let!(:bidding) { create(:bidding) }
  let(:user) { create(:admin) }

  before { oauth_token_sign_in user }

  describe '#update' do
    let(:params) { { bidding_id: bidding } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.bidding.id).to eq bidding.id }
    end

    describe 'response' do
      before do
        allow(Bidding::Minute::PdfRegenerateWorker).
          to receive(:perform_async).with(bidding.id)

          post_update
      end

      context 'when bidding has failure status' do
        let!(:bidding) { create(:bidding, status: :failure) }

        it { expect(response).to have_http_status :ok }
        it { expect(Bidding::Minute::PdfRegenerateWorker).to have_received(:perform_async).with(bidding.id) }
      end

      context 'when bidding has desert status' do
        let!(:bidding) { create(:bidding, status: :desert) }

        it { expect(response).to have_http_status :ok }
        it { expect(Bidding::Minute::PdfRegenerateWorker).to have_received(:perform_async).with(bidding.id) }
      end

      context 'when bidding has finnished status' do
        let!(:bidding) { create(:bidding, status: :finnished) }

        it { expect(response).to have_http_status :ok }
        it { expect(Bidding::Minute::PdfRegenerateWorker).to have_received(:perform_async).with(bidding.id) }
      end

      context 'when bidding does not have a failure status' do
        it { expect(response).to have_http_status :unprocessable_entity }
        it { expect(Bidding::Minute::PdfRegenerateWorker).not_to have_received(:perform_async) }
      end
    end
  end
end
