class CreateLearningItems < ActiveRecord::Migration[8.0]
  def change
    create_table :learning_items do |t|
      t.string :name
      t.string :icon
      t.string :category
      t.integer :status
      t.text :description
      t.date :started_at
      t.jsonb :resources, default: []
      t.text :notes
      t.jsonb :projects, default: []
      t.integer :position, default: 0
      t.string :source, default: 'admin'

      t.timestamps
    end
  end
end
