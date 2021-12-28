module Supp
  class BiddingSerializer < ActiveModel::Serializer
    include BiddingSerializable

    attributes :show_new_button_question

    # Item 21 do Ciclo V. 
    # Verifica se a data atual é menor ou igual à data faltando dois dias para o encerramento da
    # licitação. Utilizado para a exibição do botão de novo esclarecimento que deve ficar visível
    # ao fornecedor caso a condição seja verdadeira.
    def show_new_button_question
      object.ongoing? && Date.today <= object.closing_date - 2.days
    end
  end
end
