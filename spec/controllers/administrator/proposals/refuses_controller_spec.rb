require 'rails_helper'

RSpec.describe Administrator::Proposals::RefusesController, type: :controller do
  let(:covenant) { create(:covenant) }
  let(:user) { create(:admin) }
  let(:bidding) { create(:bidding, covenant: covenant) }
  let(:proposal) { create(:proposal, bidding: bidding, status: :sent) }
  let(:service_response) { proposal.refused! }

  before do
    allow(ProposalService::Admin::Refuse).
      to receive(:call).with(proposal: proposal) { service_response }

    oauth_token_sign_in user
  end

  describe '#update' do
    let(:params) { { proposal_id: proposal.id } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    it_behaves_like 'a version of', 'post_update', 'proposal'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.proposal).to eq proposal }
    end

    describe 'JSON' do
      
      context 'when updated' do
        before do
          # XXX: Força todas as propostas da licitação não estarem recisadas para testar
          # o fluxo sem a chamada do bidding_failure_service
          allow_any_instance_of(Bidding).to receive(:fully_refused_proposals?).and_return(false) 

          post_update
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not updated' do
        before { post_update }

        let(:service_response) { false }

        it { expect(response).to have_http_status :unprocessable_entity }
      end

      it_behaves_like "controllers/concerns/base_refuses_controller"
    end
  end
end
