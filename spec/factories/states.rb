FactoryBot.define do
  factory :state do
    sequence(:code) { |n| n }
    sequence(:uf) { |n| "E#{n}" }
    sequence(:name) { |n| "Estado #{n}" }

    trait :with_cities do
      after(:build) do |object|
        object.cities << create_list(:city, 2)
      end
    end
  end
end
