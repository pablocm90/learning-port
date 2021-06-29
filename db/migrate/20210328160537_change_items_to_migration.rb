class ChangeItemsToMigration < ActiveRecord::Migration[6.1]
  def change
    add_column :learning_stocks, :level_of_competence, :integer, default: 0
    remove_column :learning_stocks, :time_spent, :integer
    remove_column :learning_stocks, :magnitude, :string
  end
end
