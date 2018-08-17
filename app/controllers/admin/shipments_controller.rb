class Admin::ShipmentsController < Admin::ApplicationController
  load_and_authorize_resource
  before_action :find_shipment, only: [:edit, :update, :show, :destroy]

  def index
    page = params[:page] || 1
    if params[:search_query].blank?
      @shipments = Shipment.all.order(:id).page(page).per(20)
    else
      @search_query = params[:search_query]
      @shipments = Shipment.search_shipments(@search_query).order(:id).page(page).per(20)
    end
  end

  def new
    @shipment = Shipment.new(sim_id: params[:sim_id])
    if !params[:sim_id].blank?
      sim = Sim.find(params[:sim_id])
      @user = sim.user
    end
    if @user && @user.addresses.first
      address = @user.addresses.first
      @shipment.build_address(
        street_1: address.street_1,
        street_2: address.street_2,
        city: address.city,
        state: address.state,
        postal_code: address.postal_code,
        country: address.country,
        country_code: address.country_code
      )
    else
      @shipment.build_address
    end
  end

  def create
    @shipment = Shipment.new(shipment_params)
    if @shipment.save
      redirect_to admin_shipment_path(@shipment), notice: 'Shipment was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @shipment.update(shipment_params)
      redirect_to admin_shipment_path(@shipment), notice: 'Shipment was successfully updated.'
    else
      render :edit
    end
  end

  def show
    @address = @shipment.address
  end

  def destroy
    @shipment.destroy
    redirect_to admin_shipments_path, notice: 'Shipment was successfully removed.'
  end

  private

  def find_shipment
    @shipment = Shipment.find(params[:id])
  end

  def shipment_params
    params.fetch(:shipment, {}).permit(
      :tracking_number,
      :carrier,
      :status,
      :tracking_link,
      :sim_id,
      address_attributes: [:id, :street_1, :street_2, :city, :state, :postal_code, :country, :country_code]
    )
  end
end
