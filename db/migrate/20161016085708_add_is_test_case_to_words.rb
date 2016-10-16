class AddIsTestCaseToWords < ActiveRecord::Migration[5.0]
  def change
    add_column :words, :is_test_case, :string
  end
end
