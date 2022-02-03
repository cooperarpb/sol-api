# Classe responsável por armazenar as perguntas dos fornecedores
# relacionadas ao lote da licitação.
class LotQuestion < ApplicationRecord
  include ::Sortable

  belongs_to :lot
  belongs_to :supplier
  belongs_to :user, optional: true
  
  validates :question,
            :lot,
            :supplier,
            presence: true

  # método sobrescrevido do módulo Sortable
  def self.default_sort_column
    'lot_questions.created_at'
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
