class CreateSims < ActiveRecord::Migration[5.1]
  def change
    create_table :sims do |t|
      t.string :sid
      t.string :uuid
      t.string :rate_plan_sid
      t.string :name
      t.string :iccid
      t.string :e_id
      t.string :status
      t.string :phone_number
      t.string :country_code
      t.bigint :user_id
      t.index :user_id

      t.timestamps
    end
  end
end
