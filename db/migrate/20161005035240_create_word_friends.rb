class CreateWordFriends < ActiveRecord::Migration[5.0]
  def change
    create_table :word_friends do |t|
      t.references :word_from, foreign_key: true
      t.references :word_to, foreign_key: true
      t.text :traced_by
      t.string :traced_last_by

      t.timestamps
    end
  end
end
