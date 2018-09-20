FactoryBot.define do
  factory :micropost do
    sequence(:content) { |n| "Mytext#{n}" }
    created_at 10.minutes.ago
    association :user

    trait :create_3years_ago do
      created_at 3.years.ago
    end

    trait :create_2_hours_ago do
      created_at 2.hours.ago
    end

    trait :create_10_minutes_ago do
      created_at 10.minutes.ago
    end
  end
end
