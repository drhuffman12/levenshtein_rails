class AddToLengthToHistFriends < ActiveRecord::Migration[5.0]
  def change
    add_column :hist_friends, :to_length, :integer
  end
end
