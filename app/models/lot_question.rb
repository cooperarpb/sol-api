# Classe responsável por armazenar as perguntas dos fornecedores
# relacionadas ao lote da licitação.
class LotQuestion < ApplicationRecord
  belongs_to :lot
  belongs_to :supplier
  
  has_one :lot_answer

  validates :question,
            :lot,
            :supplier,
            presence: true

  delegate :answer, to: :lot_answer, allow_nil: true
end
