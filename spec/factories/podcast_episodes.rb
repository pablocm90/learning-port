FactoryBot.define do
  factory :podcast_episode do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    sequence(:episode_number)
    published_at { Faker::Date.backward(days: 30) }
    embed_code { '<iframe src="https://open.spotify.com/embed/episode/xxx"></iframe>' }
    external_links { { spotify: 'https://spotify.com', apple: 'https://apple.com' } }
  end
end
