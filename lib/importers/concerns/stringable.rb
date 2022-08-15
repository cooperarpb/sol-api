module Importers
  module Pb
    module Stringable
      def squish(attribute)
        (attribute || '').squish
      end
    end
  end
end