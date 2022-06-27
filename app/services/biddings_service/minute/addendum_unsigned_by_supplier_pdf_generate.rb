module BiddingsService::Minute
  class AddendumUnsignedBySupplierPdfGenerate < Base
    delegate :bidding, to: :contract

    private

    def minute_html_template
      Pdf::Bidding::Minute::Addendum::UnsignedBySupplierHtml.call(contract: contract)
    end

    def file_type
      'minute_addendum'
    end
  end
end
