FactoryBot.define do
  factory :podcast_category do
    sequence(:name) { |n| "Podcast Category #{n}" }
    position { 0 }
  end
end
