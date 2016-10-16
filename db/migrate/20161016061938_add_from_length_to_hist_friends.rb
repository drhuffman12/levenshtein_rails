class AddFromLengthToHistFriends < ActiveRecord::Migration[5.0]
  def change
    add_column :hist_friends, :from_length, :integer
  end
end
