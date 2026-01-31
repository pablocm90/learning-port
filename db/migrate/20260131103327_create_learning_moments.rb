class CreateLearningMoments < ActiveRecord::Migration[8.0]
  def change
    create_table :learning_moments do |t|
      t.references :category, null: false, foreign_key: true
      t.integer :engagement_type, null: false
      t.string :description, null: false
      t.string :url
      t.date :occurred_at, null: false

      t.timestamps
    end
  end
end
