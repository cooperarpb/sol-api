module LotQuestionSerializable
  extend ActiveSupport::Concern

  included do
    attributes :id, :question, :answer

    def answer
      object&.answer
    end
  end
end