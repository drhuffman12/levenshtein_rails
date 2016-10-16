class AddTraversedIdsToWords < ActiveRecord::Migration[5.0]
  def change
    add_column :words, :traversed_ids, :string
  end
end
