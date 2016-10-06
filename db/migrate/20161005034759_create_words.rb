class CreateWords < ActiveRecord::Migration[5.0]
  def change
    create_table :words do |t|
      t.string :name
      t.integer :length
      t.references :word_length, foreign_key: true
      t.references :histogram, foreign_key: true

      t.timestamps
    end
  end
end
