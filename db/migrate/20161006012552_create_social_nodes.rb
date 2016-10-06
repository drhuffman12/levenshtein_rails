class CreateSocialNodes < ActiveRecord::Migration[5.0]
  def change
    create_table :social_nodes do |t|
      t.references :word_orig, foreign_key: true
      t.references :word_from, foreign_key: true
      t.references :word_to, foreign_key: true
      t.integer :qty_steps

      t.timestamps
    end
  end
end
