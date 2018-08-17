class WebAppController < ApplicationController
  before_action :find_user_by_payment_token, only: [:add_payment_no_login, :add_payment_and_data]

  def index
  end

  def account_settings
  end

  def add_payment_no_login
    if @user
      if @user.add_payment_token_expires > DateTime.now
        render :add_payment_no_login, layout: 'auth'
      else
        render :add_payment_no_login_expired, layout: 'auth'
      end
    else
      render plain: t('invalid')
    end
  end

  def add_payment_and_data
    # Add a new payment source for user using stripe,
    # charge account for data, and update user's data plan with more data
    begin
      customer = Stripe::Customer.retrieve(@user.stripe_customer.stripe_id)
      # Add the card
      card = customer.sources.create(source: params[:stripe_token])
      @user.stripe_customer.default_source = card.id
      @user.stripe_customer.save!
      # Update user's data plan
      if @user.data_plan.add_500_mbs_and_charge
        render :successfully_added_payment_and_data, layout: 'auth'
      else
        render plain: t('errors.add_payment_and_data', error: t('error.failed_to_add_data'))
      end
    rescue => e
      STDERR.puts("Failed to add stripe payment source to customer: #{e}")
      render plain: t('errors.add_payment_and_data', error: e)
    end 
  end

  private

  def find_user_by_payment_token
    @user_token = params[:user_token]
    @user = User.find_by_add_payment_token(@user_token)
  end
end
