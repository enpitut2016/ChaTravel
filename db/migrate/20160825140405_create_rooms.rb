class CreateRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.boolean :enable
      t.string :url, :null => false, :limit => 12

      t.timestamps
    end
    add_index :rooms, :url, :unique => true
  end
end
