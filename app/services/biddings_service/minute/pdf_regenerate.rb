# Gera novamente um pdf com o mesmo conteúdo das atas já existentes
# Caso não existam atas prévias, gera um novo pdf com o conteúdo do template
module BiddingsService::Minute
  class PdfRegenerate < Base
    private

    def minute_html_template
      template_service.call
    end

    def template_service
      Pdf::Bidding::Minute::TemplateStrategy.decide(bidding: bidding)
    end

    def file_type
      'minute'
    end

    def pdf_generate
      execute_or_rollback do
        if minute_documents.present?
          merge_all_minute_documents!
        else
          super
        end
      end
    end
  end
end
