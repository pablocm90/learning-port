# frozen_string_literal: true

class CreateMilestones < ActiveRecord::Migration[6.1]
  def change
    create_table :milestones do |t|
      t.string :label
      t.boolean :reached

      t.timestamps
    end
  end
end
