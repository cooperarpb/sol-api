module Administrator
  class LotSerializer < ActiveModel::Serializer
    include LotSerializable

    attribute :estimated_cost_total

    def estimated_cost_total
      object.estimated_cost_total || 0
    end
  end
end
