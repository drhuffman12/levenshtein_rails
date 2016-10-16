class AddSocNetSizeToWords < ActiveRecord::Migration[5.0]
  def change
    add_column :words, :soc_net_size, :integer
  end
end
