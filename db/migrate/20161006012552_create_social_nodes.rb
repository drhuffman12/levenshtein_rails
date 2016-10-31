class CreateSocialNodes < ActiveRecord::Migration[5.0]
  # def change
  #   create_table :social_nodes do |t|
  #     t.references :word_orig, foreign_key: true
  #     t.references :word_from, foreign_key: true
  #     t.references :word_to, foreign_key: true
  #     t.integer :qty_steps
  #
  #     t.timestamps
  #   end
  # end
  def change
    add_column :social_nodes, :qty_steps, :integer
    add_reference :social_nodes, :word_orig, foreign_key: {to_table: :words}
    add_reference :social_nodes, :word_from, foreign_key: {to_table: :words}
    add_reference :social_nodes, :word_to, foreign_key: {to_table: :words}
  end
end
