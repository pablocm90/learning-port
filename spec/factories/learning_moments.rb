FactoryBot.define do
  factory :learning_moment do
    category
    engagement_type { :consumed }
    description { Faker::Lorem.sentence }
    url { nil }
    occurred_at { Faker::Date.backward(days: 365) }
  end
end
