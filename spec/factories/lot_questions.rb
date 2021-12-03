FactoryBot.define do
  factory :lot_question do
    lot
    supplier
    user nil
    question "My Question"
    answer ""
  end
end
