FactoryBot.define do
  factory :user do
    name Faker::Name.name
    sequence(:email) { |n| "tester#{n}@example.com" }
    password "foobar"
    admin false

    trait :admin do
      admin true
    end

  end
end
