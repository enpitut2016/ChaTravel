class CreateDecideds < ActiveRecord::Migration[5.0]
  def change
    create_table :decideds do |t|
      t.ireferences :room
      t.refences :suggest

      t.timestamps
    end
  end
end
