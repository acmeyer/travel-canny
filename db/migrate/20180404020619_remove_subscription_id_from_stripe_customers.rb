class RemoveSubscriptionIdFromStripeCustomers < ActiveRecord::Migration[5.1]
  def change
    remove_column :stripe_customers, :stripe_subscription_id, :string
  end
end
