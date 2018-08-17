class AddAddPaymentColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :add_payment_token, :string
    add_column :users, :add_payment_token_expires, :datetime
  end
end
