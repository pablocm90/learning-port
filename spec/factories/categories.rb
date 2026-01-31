FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    position { 0 }
  end
end
