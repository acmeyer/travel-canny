class Admin::TripsController < Admin::ApplicationController
  load_and_authorize_resource
  before_action :find_user
  before_action :find_trip, only: [:edit, :update, :show, :destroy]

  def new
    @trip = @user.trips.build
  end

  def create
    @trip = @user.trips.build(trip_params)
    if @trip.save
      redirect_to admin_user_path(@user), notice: 'Trip was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @trip.update(trip_params)
      redirect_to admin_user_path(@user), notice: 'Trip was successfully updated.'
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    @trip.destroy
    redirect_to admin_user_path(@user), notice: 'Trip was successfully removed.'
  end

  private
  def find_user
    @user = User.find(params[:user_id]) unless params[:user_id].blank?
  end

  def find_trip
    @trip = Trip.find(params[:id])
  end

  def trip_params
    params.fetch(:trip, {}).permit(
      country_ids: []
    )
  end
end
