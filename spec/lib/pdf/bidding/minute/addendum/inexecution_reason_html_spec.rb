require 'rails_helper'

RSpec.describe Pdf::Bidding::Minute::Addendum::InexecutionReasonHtml do
  let(:user)     { create(:user) }
  let(:provider) { create(:provider) }
  let(:supplier) { create(:supplier, provider: provider, name: 'Supplier 1') }
  let(:bidding)  { create(:bidding, status: :finnished, kind: :global) }
  let(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }
  let!(:contract) do
    create(:contract, proposal: proposal, status: status, user: user, supplier: supplier,
                      supplier_signed_at: DateTime.current, user_signed_at: DateTime.current)
  end
  let(:params) { { contract: contract } }
  let(:status) { :total_inexecution }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.contract).to eq(contract) }
    it { expect(subject.html).to be_present }
  end

  describe '.call' do
    subject { described_class.call(params) }

    context 'when able to generate' do
      context 'when is total_inexecution' do
        let(:file_type) { 'minute_addendum_total_inexecution' }

        it { is_expected.not_to include("@@") }
      end

      context 'when is partial_execution?' do
        let(:status)    { :partial_execution }
        let(:file_type) { 'minute_addendum_total_inexecution' }

        it { is_expected.not_to include("@@") }
      end

      after do
        File.write(
          Rails.root.join("spec/fixtures/myfiles/#{file_type}_template.html"),
          subject
        )
      end
    end

    context 'when not able to generate' do
      let(:status) { :signed }

      it { is_expected.to be_nil }
    end
  end
end
