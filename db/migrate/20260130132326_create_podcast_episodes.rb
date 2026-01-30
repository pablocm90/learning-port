class CreatePodcastEpisodes < ActiveRecord::Migration[8.0]
  def change
    create_table :podcast_episodes do |t|
      t.string :title
      t.text :description
      t.integer :episode_number
      t.date :published_at
      t.text :embed_code
      t.jsonb :external_links, default: {}

      t.timestamps
    end

    add_index :podcast_episodes, :episode_number, unique: true
  end
end
