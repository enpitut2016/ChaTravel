class AddTitleToSuggests < ActiveRecord::Migration[5.0]
  def change
    add_column :suggests, :title, :text
  end
end
