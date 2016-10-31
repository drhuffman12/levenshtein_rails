class CreateTables < ActiveRecord::Migration[5.0]
  def change
    create_table :word_lengths do |t|
      t.timestamps
    end
    create_table :words do |t|
      t.timestamps
    end
    create_table :word_friends do |t|
      t.timestamps
    end
    create_table :hist_friends do |t|
      t.timestamps
    end
    create_table :social_nodes do |t|
      t.timestamps
    end
    create_table :histograms do |t|
      t.timestamps
    end
  end
end
