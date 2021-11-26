require 'rails_helper'

RSpec.describe Supp::Biddings::Lots::LotQuestionsController, type: :controller do
  let(:serializer) { Supp::LotQuestionSerializer }
  let(:bidding) { create(:bidding, status: :ongoing) }
  let(:lot) { create(:lot, status: :waiting) }
  let(:user) { create(:supplier) }
  let(:lot_question) { create(:lot_question, lot: lot, supplier: user) }

  before do
    oauth_token_sign_in user

    bidding.lots << lot
  end

  describe '#index' do
    let(:params) { { bidding_id: bidding.id, lot_id: lot.id } }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { LotQuestion }
    end

    describe 'helpers' do
      let!(:params) do
        { bidding_id: bidding.id, lot_id: lot.id, page: 2 }
      end

      let(:lot_questions) { LotQuestion.all }

      before do
        allow(lot_questions).to receive(:sorted) { lot_questions }
        allow(lot_questions).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:lot_questions) { lot_questions }

        get_index
      end

      it { expect(lot_questions).to have_received(:sorted).with('lot_questions.created_at', :desc) }
      it { expect(lot_questions).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      describe 'http_status' do
        before { get_index }

        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        let(:stub_lot_questions) { LotQuestion.all }

        before do
          allow(LotQuestion).to receive(:by_supplier).with(user) { stub_lot_questions }
          allow(stub_lot_questions).to receive(:by_lot).with(lot) { LotQuestion.all }

          get_index
        end

        it { expect(LotQuestion).to have_received(:by_supplier).with(user) }
        it { expect(stub_lot_questions).to have_received(:by_lot).with(lot) }
      end

      describe 'JSON' do
        let(:lot_questions) { LotQuestion.all }

        before { get_index }

        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { lot_questions.map { |lot_question| format_json(serializer, lot_question) } }

        it { expect(json).to match_array expected_json }
      end
    end

  end

  describe '#create' do
    let(:lot_question) { build(:lot_question, lot: lot, supplier: user) }
    let(:params) { { bidding_id: bidding.id, lot_id: lot.id, lot_question: lot_question.attributes } }

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    describe 'exposes' do
      it { expect{ post_create }.to change{ LotQuestion.count }.by(1) }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before do
          allow(controller.lot_question).to receive(:save) { true }
          post_create
        end

        it { expect(response).to have_http_status :created }
        it { expect(json['lot_question']).to be_present }
      end

      context 'when not created' do
        before do
          allow(controller.lot_question).to receive(:save) { false }
          allow(controller.lot_question).to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end