class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.references :addressable, :polymorphic => true, :null => false
      t.string :street_1, :null => false
      t.string :street_2
      t.string :city, :null => false
      t.string :state
      t.string :postal_code, :null => false
      t.string :country
      t.string :country_code
      t.timestamps
    end
  end
end