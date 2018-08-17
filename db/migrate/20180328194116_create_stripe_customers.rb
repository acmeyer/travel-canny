class CreateStripeCustomers < ActiveRecord::Migration[5.1]
  def up
    create_table :stripe_customers do |t|
      t.string :stripe_id
      t.string :stripe_subscription_id
      t.string :default_source
      t.references :billable, polymorphic: true, index: true

      t.timestamps
    end

    User.all.each do |u|
      result = Stripe::Customer.create(
          :description => u.name,
          :email => u.email
      )
  
      customer = u.build_stripe_customer do |cust|
        cust.stripe_id = result.id
      end
  
      customer.save
    end
  end

  def down
    drop_table :stripe_customers
  end
end
