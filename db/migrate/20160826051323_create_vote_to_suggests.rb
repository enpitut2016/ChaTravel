class CreateVoteToSuggests < ActiveRecord::Migration[5.0]
  def change
    create_table :vote_to_suggests do |t|
      t.references :vote, foreign_key: true
      t.references :suggest, foreign_key: true

      t.timestamps
    end
  end
end
