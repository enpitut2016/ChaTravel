class RenameTextColumnToSuggests < ActiveRecord::Migration[5.0]
  def change
    rename_column :suggests, :text, :description
  end
end
