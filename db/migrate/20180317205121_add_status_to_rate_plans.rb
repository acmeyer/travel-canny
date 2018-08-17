class AddStatusToRatePlans < ActiveRecord::Migration[5.1]
  def change
    add_column :rate_plans, :status, :integer, default: 0
  end
end
