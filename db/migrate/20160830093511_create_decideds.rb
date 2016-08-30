class CreateDecideds < ActiveRecord::Migration[5.0]
  def change
    create_table :decideds do |t|
      t.references :room, foreign_key: true
      t.references :suggest, foreign_key: true

      t.timestamps
    end
  end
end
