class CreateHistograms < ActiveRecord::Migration[5.0]
  # def change
  #   create_table :histograms do |t|
  #     t.text :hist
  #     t.integer :length
  #     t.references :word_length, foreign_key: true
  #
  #     t.timestamps
  #   end
  # end
  def change
    add_column :histograms, :hist, :text
    add_column :histograms, :length, :integer
    add_reference :histograms, :word_length, foreign_key: true
  end
end
