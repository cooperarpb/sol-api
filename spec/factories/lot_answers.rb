FactoryBot.define do
  factory :lot_answer do
    lot_question
    user
    answer "My Answer"
  end
end
