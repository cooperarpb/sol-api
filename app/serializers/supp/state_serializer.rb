module Supp
  class StateSerializer < ActiveModel::Serializer
    attributes :id, :text

    def text
      object.name
    end
  end
end