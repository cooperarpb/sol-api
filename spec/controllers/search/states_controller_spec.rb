require 'rails_helper'

RSpec.describe Search::StatesController, type: :controller do
  let(:states) { create_list(:state, 2) }

  describe '#index' do
    describe 'processing' do
      let(:json_response) { JSON.load(response.body).to_json }
      let(:result_arr) do 
        [
          { id: states.first.id, text: states.first.text }, 
          { id: states.second.id, text: states.second.text }
        ].to_json
      end

      before do
        states

        get :index, xhr: true
      end

      it { is_expected.to respond_with(:success) }
      it { expect(json_response).to eq(result_arr) }
    end
  end
end
