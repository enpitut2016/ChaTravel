class CreateSuggests < ActiveRecord::Migration[5.0]
  def change
    create_table :suggests do |t|
      t.string :url
      t.text :text
      t.references :room, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
