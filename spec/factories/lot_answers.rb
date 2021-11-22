FactoryBot.define do
  factory :lot_answer do
    lot_question
    user
    answer "MyText"
  end
end
