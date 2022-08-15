module Importers
  module Pb
    module Maskable
      def mask_cep(cep)
        ZipCode.mask(cep)
      end 

      def mask_cnpj(number)
        CNPJ.mask(number)
      end
    end
  end
end