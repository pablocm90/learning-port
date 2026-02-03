FactoryBot.define do
  factory :podcast_category do
    sequence(:name) { |n| "Podcast Category #{n}" }
    sequence(:slug) { |n| "podcast-category-#{n}" }
    position { 0 }
  end
end
