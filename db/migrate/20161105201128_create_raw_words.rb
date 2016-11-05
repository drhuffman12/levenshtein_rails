class CreateRawWords < ActiveRecord::Migration[5.0]
  def change
    create_table :raw_words do |t|
      t.string :name
      t.string :is_test_case
      t.references :word, foreign_key: true

      t.timestamps
    end
  end
end
