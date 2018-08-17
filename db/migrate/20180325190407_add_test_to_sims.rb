class AddTestToSims < ActiveRecord::Migration[5.1]
  def change
    add_column :sims, :test_sim, :boolean, default: false
  end
end
