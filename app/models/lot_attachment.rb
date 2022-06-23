class LotAttachment < ApplicationRecord
  include ::Sortable

  belongs_to :lot
  belongs_to :supplier
  has_one :attachment, as: :attachable, dependent: :destroy

  enum status: { pending: 0, sent: 1 }

  accepts_nested_attributes_for :attachment, allow_destroy: true

  # método sobrescrevido do módulo Sortable
  def self.default_sort_column
    'lot_attachments.created_at'
  end

  # método sobrescrevido do módulo Sortable
  def self.default_sort_direction
    :desc
  end

  def self.by_supplier(supplier_id)
    where(supplier_id: supplier_id)
  end

  def self.by_lot(lot_id)
    where(lot_id: lot_id)
  end
end
