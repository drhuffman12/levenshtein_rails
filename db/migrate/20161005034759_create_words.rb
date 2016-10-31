class CreateWords < ActiveRecord::Migration[5.0]
  # def change
  #   create_table :words do |t|
  #     t.string :name
  #     t.integer :length
  #     t.references :word_length, foreign_key: true
  #     t.references :histogram, foreign_key: true
  #
  #     t.timestamps
  #   end
  # end
  def change
    add_column :words, :name, :string
    add_column :words, :length, :integer
    add_reference :words, :word_length, foreign_key: true
    add_reference :words, :histogram, foreign_key: true
  end
end
