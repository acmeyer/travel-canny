class AddActivationCodeToSims < ActiveRecord::Migration[5.1]
  def change
    add_column :sims, :activation_code, :string
  end
end
