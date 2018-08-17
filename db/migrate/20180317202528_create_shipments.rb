class CreateShipments < ActiveRecord::Migration[5.1]
  def change
    create_table :shipments do |t|
      t.bigint :sim_id
      t.index :sim_id
      t.string :tracking_number
      t.string :carrier
      t.integer :status
      t.string :tracking_link

      t.timestamps
    end
  end
end
