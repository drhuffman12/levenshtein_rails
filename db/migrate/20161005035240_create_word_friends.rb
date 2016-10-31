class CreateWordFriends < ActiveRecord::Migration[5.0]
  # def change
  #   create_table :word_friends do |t|
  #     t.references :word_from, foreign_key: true
  #     t.references :word_to, foreign_key: true
  #     t.text :traced_by
  #     t.string :traced_last_by
  #
  #     t.timestamps
  #   end
  # end
  def change
    add_column :word_friends, :traced_by, :text
    add_column :word_friends, :traced_last_by, :string
    add_reference :word_friends, :word_from, foreign_key: {to_table: :words}
    add_reference :word_friends, :word_to, foreign_key: {to_table: :words}
  end
end
