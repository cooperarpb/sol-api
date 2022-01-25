require 'rails_helper'

RSpec.describe Search::StatesController, type: :controller do
  let(:states) { create_list(:state, 26) }
  let(:state) { states.first }
  let(:limit) { SearchService::Base::LIMIT }

  describe '#index' do
    describe 'limit' do
      it { expect(SearchService::Base::LIMIT).to eq 15 }
    end

    describe 'processing' do
      let(:params) { ActionController::Parameters.new({ search: { term: state.name }, "controller"=>"search/states", "action"=>"index" }) }
      let(:json_response) { JSON.load(response.body)[0].to_json }
      let(:result_arr) { [{ id: state.id, text: state.text }].to_json }

      before do
        allow(State).to receive(:search).with(state.name, limit).and_call_original
        allow(SearchService::Base).to receive(:call).and_return(result_arr)
        get :index, params: params.as_json, xhr: true
      end

      it { is_expected.to respond_with(:success) }
      it { expect(SearchService::Base).to have_received(:call).with(params, State, nil) }
    end
  end
end
