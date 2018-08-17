class CreateDataPlans < ActiveRecord::Migration[5.1]
  def up
    create_table :data_plans do |t|
      t.belongs_to :user, index: true
      t.string :units, default: "bytes"
      t.bigint :total_amount, default: 1000000000
      t.bigint :total_amount_used, default: 0
      t.bigint :warning_amount, default: 50000000
      t.integer :status, default: 0

      t.timestamps
    end

    User.all.each do |u|
      u.create_data_plan!
    end
  end

  def down
    drop_table :data_plans
  end
end
