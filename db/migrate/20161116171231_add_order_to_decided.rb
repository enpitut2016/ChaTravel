class AddOrderToDecided < ActiveRecord::Migration[5.0]
  def change
    add_column :decideds, :order, :integer
  end
end
