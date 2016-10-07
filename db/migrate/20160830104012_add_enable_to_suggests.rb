class AddEnableToSuggests < ActiveRecord::Migration[5.0]
  def change
    add_column :suggests, :enable, :boolean, default: true, null: false
  end
end
