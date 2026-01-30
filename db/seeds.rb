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
# Podcast Episodes from YAML
# =============================================================================
puts "\nSeeding podcast episodes from YAML..."

podcast_episodes_path = Rails.root.join('db/seeds/podcast_episodes.yml')
if File.exist?(podcast_episodes_path)
  podcast_episodes = YAML.safe_load_file(podcast_episodes_path, permitted_classes: [Date, Time, DateTime]) || []
  created_count = 0
  updated_count = 0

  podcast_episodes.each do |episode_data|
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
      if was_new
        created_count += 1
        puts "  -> Created: Episode #{episode.episode_number} - #{episode.title}"
      else
        updated_count += 1
        puts "  -> Updated: Episode #{episode.episode_number} - #{episode.title}"
      end
    else
      puts "  -> Failed: Episode #{episode_data['episode_number']} - #{episode.errors.full_messages.join(', ')}"
    end
  end

  puts "  Podcast episodes: #{created_count} created, #{updated_count} updated"
else
  puts "  -> No podcast_episodes.yml found, skipping..."
end

puts "\nSeeding complete!"
