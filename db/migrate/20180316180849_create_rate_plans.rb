class CreateRatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :rate_plans do |t|
      t.string :sid
      t.string :uuid
      t.string :name
      t.integer :data_amount
      t.integer :voice_minutes
      t.integer :sms_amount
      t.string :country
      t.string :region
      t.bigint :sim_id
      t.index :sim_id

      t.timestamps
    end
  end
end
