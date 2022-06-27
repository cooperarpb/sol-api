module Pdf::Bidding::Minute
  class Addendum::UnsignedBySupplierHtml < Addendum::Base
    private

    # @override
    def template_file_name
      'addendum_unsigned_by_supplier.html'
    end

    # @override
    def contract_not_able_to_generate?
      ! contract.unsigned_by_supplier?
    end

    # @override
    def dictionary
      {
        '@@contract.status.text@@' => contract_status_text,
        '@@cooperative.legal_representative.name@@' => cooperative.legal_representative.name,
        '@@cooperative.name@@' => cooperative.name,
        '@@current_date@@' => format_date(Date.current)
      }
    end

    # @override
    def contract_status_text
      I18n.t('document.pdf.bidding.minute.contract_unsigned_by_supplier') %
        [contract.id, contract&.proposal&.provider&.name, ::Contract::SUPPLIER_SIGNATURE_DEADLINE]
    end
  end
end
