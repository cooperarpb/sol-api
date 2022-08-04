require 'rails_helper'

RSpec.describe Supp::ProvidersController, type: :controller do
  before { oauth_token_sign_in supplier }

  let(:supplier) { create :supplier, provider: resource }
  let(:resource) { create :provider }

  describe '#profile' do
    context 'when params are valid' do
      context 'and password param is present' do
        subject { patch :profile, params: valid_params_with_password, xhr: true }

        let(:valid_params_with_password) { { provider: resource.attributes } }

        it { is_expected.to have_http_status :ok }
      end

      context 'and password param is not present' do
        subject { patch :profile, params: valid_params_without_password, xhr: true }

        let(:valid_params_without_password) { { provider: resource.attributes.except!(:password, :password_confirmation) } }

        it { is_expected.to have_http_status :ok }
      end
    end

    context 'when params are not valid' do
      subject { patch :profile, params: invalid_params, xhr: true }

      let(:invalid_params) { { provider: resource.attributes.merge!("name" => "") } }

      it { is_expected.to have_http_status :unprocessable_entity }
    end
  end

  describe '#find_current_provider' do
    context 'when current_provider is present' do
      subject { get :find_current_provider, xhr: true }

      it { is_expected.to have_http_status :ok }
    end

    context 'when current_provider is not present' do
      subject { get :find_current_provider, xhr: true }

      before do
        allow(controller).to receive(:current_provider).and_return(nil)
      end

      it { is_expected.to have_http_status :unprocessable_entity }
    end
  end
end
