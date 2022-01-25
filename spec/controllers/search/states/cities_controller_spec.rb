require 'rails_helper'

RSpec.describe Search::States::CitiesController, type: :controller do
  let(:states) { create_list(:state, 2, :with_cities) }
  let(:state) { states.first }
  let(:city) { states.first.cities.first }
  let(:limit) { SearchService::Base::LIMIT }

  describe '#index' do
    describe 'limit' do
      it { expect(SearchService::Base::LIMIT).to eq 15 }
    end

    describe 'processing' do
      let(:params) { ActionController::Parameters.new({ search: { term: city.name }, state_id: state.id, "controller"=>"search/states/:state_id/cities", "action"=>"index" }) }
      let(:result_arr) { [{ id: city.id, text: city.text }].to_json }

      before do
        allow(State).to receive(:search).with(state.name, limit).and_call_original
        allow(SearchService::Base).to receive(:call).and_return(result_arr)
        get :index, params: params.as_json, xhr: true
      end

      it { is_expected.to respond_with(:success) }
      it { expect(response.body).to eq result_arr }
      it { expect(response.content_type).to eq 'application/json' }
    end
  end
end
