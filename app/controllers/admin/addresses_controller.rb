class Admin::AddressesController < Admin::ApplicationController
  load_and_authorize_resource
  before_action :find_user
  before_action :find_address, only: [:edit, :update, :show, :destroy]

  def new
    @address = @user.build_shipping_address
  end

  def create
    @address = @user.build_shipping_address(address_params)
    if @address.save
      redirect_to admin_user_path(@user), notice: 'Address was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to admin_user_path(@user), notice: 'Address was successfully updated.'
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    @address.destroy
    redirect_to admin_addresss_path, notice: 'Address was successfully removed.'
  end

  private
  def find_user
    @user = User.find(params[:user_id])
  end

  def find_address
    @address = Address.find(params[:id])
  end

  def address_params
    params.fetch(:address, {}).permit(
      :street_1,
      :street_2,
      :city,
      :state,
      :postal_code,
      :country,
      :country_code
    )
  end
end
