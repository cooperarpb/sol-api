require 'rails_helper'

RSpec.describe Coop::ClassificationsController, type: :controller do
  let(:serializer) { ClassificationSerializer }
  let(:user) { create(:user) }

  let!(:parents_classifications) { create_list(:classification, 3) }
  let!(:first_child_classification) { create(:classification, classification: parents_classifications.first, name: 'B') }
  let!(:second_child_classification) { create(:classification, classification: parents_classifications.first, name: 'A') }

  let(:classifications) { parents_classifications }

  before { oauth_token_sign_in user }

  describe '#index' do
    context 'when parent_classification_id is not present' do
      let(:sorted_classifications) do
        Classification.where(id: parents_classifications.map(&:id)).sorted
      end

      subject(:get_index) { get :index, xhr: true }

      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) do
          sorted_classifications.map { |classification| format_json(serializer, classification) }
        end

        it { expect(json).to eq expected_json }
      end
    end

    context 'when parent_classification_id is present' do
      subject(:get_index) { get :index, params: { parent_classification_id: parents_classifications.first }, xhr: true }
      
      let(:sorted_classifications) do
        [second_child_classification, first_child_classification]
      end

      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) do
          sorted_classifications.map { |classification| format_json(serializer, classification) }
        end

        it { expect(json).to eq expected_json }
      end
    end
  end

end
