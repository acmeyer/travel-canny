class CreateCountries < ActiveRecord::Migration[5.1]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :country_code
      t.json :emergency_phone_numbers
      t.string :underrated
      t.string :overrated
      t.string :fun_facts, array: true

      t.timestamps
    end
  end
end
