class CreateHistFriends < ActiveRecord::Migration[5.0]
  def change
    create_table :hist_friends do |t|
      t.references :hist_from, foreign_key: true
      t.references :hist_to, foreign_key: true
      t.text :traced_by
      t.string :traced_last_by

      t.timestamps
    end
  end
end
