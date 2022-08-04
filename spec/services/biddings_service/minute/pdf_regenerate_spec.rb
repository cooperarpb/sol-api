require 'rails_helper'

RSpec.describe BiddingsService::Minute::PdfRegenerate, type: :service do
  let(:bidding) { create(:bidding) }
  let(:params) { { bidding: bidding } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
  end

  describe '.call!' do
    context 'when bidding already has minute documents' do
      let(:minute_document) { create(:document) }
      
      before do
        bidding.minute_documents << minute_document
        
        described_class.call!(params)
      end

      it { expect(bidding.minute_documents.size).to eq(1) }
      it { expect(bidding.merged_minute_document).to be_present }
    end

    context 'when bidding does not have minute documents' do
      let(:minute_pdf_generate_return) do
        Rack::Test::UploadedFile.new(
          Rails.root.join("spec/fixtures/myfiles/file.pdf")
        )
      end

      before do
        allow(Pdf::Bidding::Minute::TemplateStrategy).
          to receive(:decide).and_return(double('call', call: nil))
        allow(Pdf::Builder::Bidding).
          to receive(:call).and_return(minute_pdf_generate_return)
        allow(Pdf::Merge).
          to receive(:call).and_return(minute_pdf_generate_return)

        described_class.call!(params)
      end

      it { expect(bidding.minute_documents.size).to eq(1) }
      it { expect(bidding.merged_minute_document).to be_present }
    end
  end
end
