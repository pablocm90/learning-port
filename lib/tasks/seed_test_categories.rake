# frozen_string_literal: true

namespace :db do
  desc "Seed 12 test categories for paint drip visualization testing"
  task seed_test_categories: :environment do
    require 'yaml'

    puts "Clearing existing categories and moments..."
    LearningMoment.destroy_all
    Category.destroy_all

    puts "Seeding 12 test categories..."
    categories_file = Rails.root.join("db/seeds/categories_test.yml")
    categories_data = YAML.safe_load_file(categories_file, permitted_classes: [Date, Time, DateTime])

    categories_data.each do |cat_data|
      category = Category.create!(
        name: cat_data["name"],
        position: cat_data["position"]
      )

      cat_data["moments"]&.each do |moment_data|
        category.learning_moments.create!(
          description: moment_data["description"],
          engagement_type: moment_data["engagement_type"],
          occurred_at: moment_data["occurred_at"],
          url: moment_data["url"]
        )
      end

      puts "  -> #{category.name}: #{category.learning_moments.count} moments"
    end

    puts "\nDone! #{Category.count} categories with #{LearningMoment.count} learning moments"
  end
end
