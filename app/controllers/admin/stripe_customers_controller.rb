class Admin::StripeCustomersController < Admin::ApplicationController
  load_and_authorize_resource
  before_action :find_user
  before_action :find_stripe_customer, only: [:edit, :update, :show, :destroy]

  def new
    @stripe_customer = @user.build_stripe_customer
  end

  def create
    @stripe_customer = @user.build_stripe_customer(stripe_customer_params)
    if @stripe_customer.save
      redirect_to admin_user_path(@user), notice: 'Stripe customer was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @stripe_customer.update(stripe_customer_params)
      redirect_to admin_user_path(@user), notice: 'Stripe customer was successfully updated.'
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    @stripe_customer.destroy
    redirect_to admin_user_path(@user), notice: 'Stripe customer was successfully removed.'
  end

  private
  def find_user
    @user = User.find(params[:user_id]) unless params[:user_id].blank?
  end

  def find_stripe_customer
    @stripe_customer = StripeCustomer.find(params[:id])
  end

  def stripe_customer_params
    params.fetch(:stripe_customer, {}).permit(
      :stripe_id,
      :default_source
    )
  end
end
