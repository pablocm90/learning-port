FactoryBot.define do
  factory :writer do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password123' }
    bio { Faker::Lorem.paragraph }
  end
end
