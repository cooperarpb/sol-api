module Supp
  class ProviderSerializer < ActiveModel::Serializer
    include ProviderSerializable

    attributes :current_supplier

    def current_supplier
      @instance_options&.dig(:scope)
    end
  end
end
