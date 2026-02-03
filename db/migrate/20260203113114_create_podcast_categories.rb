class CreatePodcastCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :podcast_categories do |t|
      t.string :name, null: false
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :podcast_categories, :name, unique: true
  end
end
