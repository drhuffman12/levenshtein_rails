class AddFromLengthToWordFriends < ActiveRecord::Migration[5.0]
  def change
    add_column :word_friends, :from_length, :integer
  end
end
