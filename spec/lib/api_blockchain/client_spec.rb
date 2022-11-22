require 'rails_helper'

RSpec.describe ApiBlockchain::Client, type: :model do
  subject { described_class.new }

  describe '#initialize' do
    it { expect(subject.adapter).to eq Faraday.default_adapter }
    it { expect(subject.connection).to be_nil }
  end

  describe '#request' do
    let(:base_path) { Rails.application.secrets.dig(:blockchain, :hyperledger_path) }
    let(:endpoint)  {  "#{base_path}/api/Bidding" }

    describe 'token_request' do
      let(:endpoint) {  "#{base_path}/sdc/login" }
      let(:request)  { subject.request(verb: 'POST', endpoint: endpoint) }

      let(:headers) do
        {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type'=>'application/json',
          'User-Agent'=>'Faraday v0.12.2'
        }
      end
      
      before do
        stub_request(:post, endpoint).with(headers: headers).to_return(status: 200, body: '', headers: {})

        request
      end

      let(:stubbed_request) do
        a_request(:post, endpoint).with(headers: headers)
      end

      it { expect(stubbed_request).to have_been_made.once }
      it { expect(request).to be_a ApiBlockchain::Response }
    end

    describe 'request' do
      let(:endpoint) {  "#{base_path}/sdc/queryAllAssets" }
      let(:request)  { subject.request(verb: 'GET', endpoint: endpoint) }

      let(:headers) do
        {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Faraday v0.12.2'
        }
      end
      
      before do
        stub_request(:get, endpoint).with(headers: headers).to_return(status: 200, body: '', headers: {})

        request
      end

      let(:stubbed_request) do
        a_request(:get, endpoint).with(headers: headers)
      end

      it { expect(stubbed_request).to have_been_made.once }
      it { expect(request).to be_a ApiBlockchain::Response }
    end
  end
end
