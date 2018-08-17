class AddColumnsToCountries < ActiveRecord::Migration[5.1]
  def change
    add_column :countries, :official_name, :string
    add_column :countries, :alpha_2_code, :string, limit: 2
    add_column :countries, :alpha_3_code, :string, limit: 3
  end
end
