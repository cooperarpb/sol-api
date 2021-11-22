# Classe reponsável por armazenar as respostas da associação
# sobre as perguntas provenientes dos fornecedores em relação a um lote.
class LotAnswer < ApplicationRecord
  belongs_to :lot_question
  belongs_to :user

  validates :answer,
            :lot_question,
            :user,
            presence: true
end
