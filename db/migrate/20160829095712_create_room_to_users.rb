class CreateRoomToUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :room_to_users do |t|
      t.references :room
      t.references :user

      t.timestamps
    end
  end
end
