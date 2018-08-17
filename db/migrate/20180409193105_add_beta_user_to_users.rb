class AddBetaUserToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :beta_user, :boolean, default: false
  end
end
