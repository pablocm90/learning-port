# frozen_string_literal: true

require 'yaml'

# =============================================================================
# Admin Writer
# =============================================================================
puts "Seeding admin writer..."

Writer.find_or_create_by!(email: 'admin@example.com') do |writer|
  writer.name = 'Pablo'
  writer.password = 'changeme123'
  writer.bio = 'Software developer and lifelong learner.'
end

puts "  -> Admin writer ready: admin@example.com / changeme123"

# =============================================================================
# Learning Items from YAML
# =============================================================================
puts "\nSeeding learning items from YAML..."

learning_items_path = Rails.root.join('db/seeds/learning_items.yml')
if File.exist?(learning_items_path)
  learning_items = YAML.safe_load_file(learning_items_path, permitted_classes: [Date, Time, DateTime]) || []
  created_count = 0
  updated_count = 0

  learning_items.each do |item_data|
    item = LearningItem.find_or_initialize_by(name: item_data['name'])
    was_new = item.new_record?

    item.assign_attributes(
      icon: item_data['icon'],
      category: item_data['category'],
      status: item_data['status'],
      description: item_data['description'],
      started_at: item_data['started_at'],
      position: item_data['position'],
      resources: item_data['resources'] || [],
      projects: item_data['projects'] || [],
      source: 'yaml'
    )

    if item.save
      if was_new
        created_count += 1
        puts "  -> Created: #{item.name}"
      else
        updated_count += 1
        puts "  -> Updated: #{item.name}"
      end
    else
      puts "  -> Failed: #{item.name} - #{item.errors.full_messages.join(', ')}"
    end
  end

  puts "  Learning items: #{created_count} created, #{updated_count} updated"
else
  puts "  -> No learning_items.yml found, skipping..."
end

# =============================================================================
# Podcast Episodes and Categories from YAML
# =============================================================================
puts "\nSeeding podcast episodes and categories from YAML..."

podcast_data_path = Rails.root.join('db/seeds/podcast_episodes.yml')
if File.exist?(podcast_data_path)
  podcast_data = YAML.safe_load_file(podcast_data_path, permitted_classes: [Date, Time, DateTime]) || {}

  # Seed podcast categories
  categories_data = podcast_data['categories'] || []
  created_categories = 0

  categories_data.each do |cat_data|
    cat = PodcastCategory.find_or_create_by!(name: cat_data['name']) do |c|
      c.position = cat_data['position']
      c.slug = cat_data['slug']
    end
    created_categories += 1 if cat.previously_new_record?
  end
  puts "  Podcast categories: #{created_categories} created (#{PodcastCategory.count} total)"

  # Seed podcast episodes
  episodes_data = podcast_data['episodes'] || []
  created_episodes = 0
  updated_episodes = 0

  episodes_data.each do |episode_data|
    episode = PodcastEpisode.find_or_initialize_by(episode_number: episode_data['episode_number'])
    was_new = episode.new_record?

    episode.assign_attributes(
      title: episode_data['title'],
      description: episode_data['description'],
      published_at: episode_data['published_at'],
      embed_code: episode_data['embed_code'],
      external_links: episode_data['external_links'] || {}
    )

    if episode.save
      # Assign categories
      category_names = episode_data['categories'] || []
      categories = PodcastCategory.where(name: category_names)
      episode.podcast_categories = categories

      if was_new
        created_episodes += 1
        puts "  -> Created: Episode #{episode.episode_number} - #{episode.title}"
      else
        updated_episodes += 1
        puts "  -> Updated: Episode #{episode.episode_number} - #{episode.title}"
      end
    else
      puts "  -> Failed: Episode #{episode_data['episode_number']} - #{episode.errors.full_messages.join(', ')}"
    end
  end

  puts "  Podcast episodes: #{created_episodes} created, #{updated_episodes} updated"
else
  puts "  -> No podcast_episodes.yml found, skipping..."
end

# =============================================================================
# Categories and Learning Moments from YAML
# =============================================================================
puts "\nSeeding categories and learning moments from YAML..."

categories_file = Rails.root.join("db/seeds/categories.yml")
if File.exist?(categories_file)
  categories_data = YAML.safe_load_file(categories_file, permitted_classes: [Date, Time, DateTime]) || []
  created_categories = 0
  created_moments = 0

  categories_data.each do |cat_data|
    category = Category.find_or_create_by!(name: cat_data["name"]) do |c|
      c.position = cat_data["position"]
    end
    created_categories += 1 if category.previously_new_record?

    cat_data["moments"]&.each do |moment_data|
      moment = category.learning_moments.find_or_create_by!(
        description: moment_data["description"],
        occurred_at: moment_data["occurred_at"]
      ) do |m|
        m.engagement_type = moment_data["engagement_type"]
        m.url = moment_data["url"]
      end
      created_moments += 1 if moment.previously_new_record?
    end
    puts "  -> Loaded category: #{category.name} with #{cat_data['moments']&.size || 0} moments"
  end

  puts "  Categories: #{created_categories} created, Learning moments: #{created_moments} created"
  puts "  Total: #{Category.count} categories with #{LearningMoment.count} learning moments"
else
  puts "  -> No categories.yml found, skipping..."
end

puts "\nSeeding complete!"
