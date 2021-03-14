# frozen_string_literal: true

class CreateLearningStocks < ActiveRecord::Migration[6.1]
  def change
    create_table :learning_stocks do |t|
      t.string :name
      t.string :icon
      t.string :desired_weight
      t.integer :time_spent
      t.string :magnitude

      t.timestamps
    end
  end
end
