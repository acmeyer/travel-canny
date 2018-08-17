class DropOldColumnsFromCountries < ActiveRecord::Migration[5.1]
  def change
    remove_column :countries, :country_code, :string
    remove_column :countries, :emergency_phone_numbers, :json
    remove_column :countries, :underrated, :string
    remove_column :countries, :overrated, :string
    remove_column :countries, :fun_facts, :text, array: true
  end
end
