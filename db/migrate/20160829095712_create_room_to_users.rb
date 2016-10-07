class CreateRoomToUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :room_to_users do |t|
      t.integer :room_id
      t.integer :user_id

      t.timestamps
    end
    add_index :room_to_users, :room_id
    add_index :room_to_users, :user_id
    add_index :room_to_users, [:room_id, :user_id], unique: true
  end
end
