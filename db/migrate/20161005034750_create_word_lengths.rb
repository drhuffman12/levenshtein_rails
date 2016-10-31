class CreateWordLengths < ActiveRecord::Migration[5.0]
  # def change
  #   create_table :word_lengths do |t|
  #     t.integer :length
  #
  #     t.timestamps
  #   end
  # end
  def change
    add_column :word_lengths, :length, :integer
  end
end
