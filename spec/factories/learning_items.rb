FactoryBot.define do
  factory :learning_item do
    name { Faker::ProgrammingLanguage.name }
    icon { '💻' }
    category { %w[Languages Frameworks DevOps Concepts].sample }
    status { :learning }
    description { Faker::Lorem.sentence }
    started_at { Faker::Date.backward(days: 365) }
    resources { [] }
    projects { [] }
    position { 0 }
    source { 'admin' }
  end
end
