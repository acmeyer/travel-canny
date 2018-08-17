desc "Update users on Stripe"
task :update_stripe_users => [:environment] do |t|
  User.all.each do |u|
    # Destroy any existing stripe customers for user
    u.stripe_customer.destroy! unless u.stripe_customer.blank?
    # Replace with new stripe customer
    result = Stripe::Customer.create(
      description: u.name,
      email: u.email,
      shipping: {
        name: u.name,
        address: {
          line1: u.shipping_address.try(:street_1),
          line2: u.shipping_address.try(:street_2),
          city: u.shipping_address.try(:city),
          state: u.shipping_address.try(:state),
          postal_code: u.shipping_address.try(:postal_code),
          country: u.shipping_address.try(:country),
        }
      }
    )

    customer = u.build_stripe_customer do |cust|
      cust.stripe_id = result.id
    end

    customer.save
  end
end