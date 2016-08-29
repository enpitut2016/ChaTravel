class AddImageToSuggests < ActiveRecord::Migration[5.0]
  def change
    add_column :suggests, :image, :text
  end
end
