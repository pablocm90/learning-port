class AddLearningStocksToWriter < ActiveRecord::Migration[6.1]
  def change
    add_reference :learning_stocks, :writer, null: false, foreign_key: true
  end
end
