module BiddingsService::Minute
  class AddendumInexecutionReasonPdfGenerate
    include TransactionMethods
    include Call::WithExceptionsMethods

    delegate :bidding, to: :contract
    delegate :inexecution_reason_documents, to: :bidding

    def main_method
      pdf_generate
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def pdf_generate
      execute_or_rollback do
        if inexecution_reason_pdf.present?
          attach_inexecution_reason_document!
          merge_all_inexecution_reason_documents!
        end
      end
    end

    def attach_inexecution_reason_document!
      inexecution_reason_documents << create_inexecution_reason_document!
      bidding.save!
    end

    def create_inexecution_reason_document!
      create_document!(:inexecution_reason_pdf)
    end

    def merge_all_inexecution_reason_documents!
      bidding.update!(merged_inexecution_reason_document: create_merged_inexecution_reason_document!)
    end

    def create_merged_inexecution_reason_document!
      create_document!(:merged_inexecution_reason_pdf)
    end

    def create_document!(file_method)
      InexecutionReasonDocument.create!(file: send(file_method))
    end

    def inexecution_reason_pdf
      @inexecution_reason_pdf ||= Pdf::Builder::Bidding.call(html: inexecution_reason_html_template, file_type: file_type)
    end

    def merged_inexecution_reason_pdf
      Pdf::Merge.call(documents: [merged_minute_document] + inexecution_reason_documents)
    end

    def merged_minute_document
      bidding.merged_minute_document
    end

    def inexecution_reason_html_template
      Pdf::Bidding::Minute::Addendum::InexecutionReasonHtml.call(contract: contract)
    end

    def file_type
      'inexecution_reason_addendum'
    end
  end
end
