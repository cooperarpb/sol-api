# Classe responsável por armazenar as perguntas dos fornecedores
# relacionadas ao lote da licitação.
class LotQuestion < ApplicationRecord
  belongs_to :lot
  belongs_to :supplier

  validates :question,
            :lot,
            :supplier,
            presence: true
end
