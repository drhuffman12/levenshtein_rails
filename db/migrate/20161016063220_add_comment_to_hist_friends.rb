class AddCommentToHistFriends < ActiveRecord::Migration[5.0]
  def change
    add_column :hist_friends, :comment, :string
  end
end
