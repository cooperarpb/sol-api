# Classe responsável por preencher as informações necessárias no template 
# addendum_inexecution_reason.html que exibe o motivo da inexecução total ou parcial
# informado pela associação
#
module Pdf::Bidding::Minute
  class Addendum::InexecutionReasonHtml < Addendum::Base
    private

    def template_file_name
      'addendum_inexecution_reason.html'
    end

    def contract_status
      I18n.t("activerecord.attributes.contract.statuses.#{contract.status}")
    end

    def contract_title
      contract.title
    end

    def contract_inexecution_reason
      contract.inexecution_reason
    end

    def contract_not_able_to_generate?
      ! (contract.total_inexecution? || contract.partial_execution?)
    end

    # override
    def dictionary
      {
        '@@contract.status@@' => contract_status,
        '@@contract.title@@' => contract_title,
        '@@contract.inexecution_reason@@' => contract_inexecution_reason,
        '@@cooperative.legal_representative.name@@' => cooperative.legal_representative.name,
        '@@cooperative.name@@' => cooperative.name,
        '@@current_date@@' => format_date(Date.current)
      }
    end
  end
end
