FactoryBot.define do
  factory :user do
    name Faker::Name.name
    sequence(:email) { |n| "tester#{n}@example.com" }
    password "foobar"
    admin false
    activated true
    activated_at Time.zone.now

    trait :admin do
      admin true
    end
  end
end
