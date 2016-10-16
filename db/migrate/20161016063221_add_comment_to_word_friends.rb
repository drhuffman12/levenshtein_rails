class AddCommentToWordFriends < ActiveRecord::Migration[5.0]
  def change
    add_column :word_friends, :comment, :string
  end
end
