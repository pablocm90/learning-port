class AddSlugToPodcastCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :podcast_categories, :slug, :string

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE podcast_categories
          SET slug = LOWER(REPLACE(REPLACE(REPLACE(TRIM(name), ' & ', '-and-'), ' ', '-'), '&', '-and-'))
          WHERE slug IS NULL OR slug = ''
        SQL
      end
    end

    change_column_null :podcast_categories, :slug, false, ''
    add_index :podcast_categories, :slug, unique: true
  end
end
