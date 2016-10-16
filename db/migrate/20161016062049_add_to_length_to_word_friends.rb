class AddToLengthToWordFriends < ActiveRecord::Migration[5.0]
  def change
    add_column :word_friends, :to_length, :integer
  end
end
