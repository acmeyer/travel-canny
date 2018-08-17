class ChangeStatusToEnumOnSims < ActiveRecord::Migration[5.1]
  def change
    change_column :sims, :status, :integer, default: 0, using: 'status::integer'
  end
end
