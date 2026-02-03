class CreatePodcastEpisodeCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :podcast_episode_categories do |t|
      t.references :podcast_episode, null: false, foreign_key: true
      t.references :podcast_category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :podcast_episode_categories, [:podcast_episode_id, :podcast_category_id],
              unique: true, name: 'idx_episode_categories_unique'
  end
end
