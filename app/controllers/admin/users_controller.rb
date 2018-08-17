class Admin::UsersController < Admin::ApplicationController
  load_and_authorize_resource
  before_action :find_user, only: [:edit, :update, :show, :destroy]

  def index
    page = params[:page] || 1
    if params[:search_query].blank?
      @users = User.all.order(:id).page(page).per(20)
    else
      @search_query = params[:search_query]
      @users = User.search_users(@search_query).order(:id).page(page).per(20)
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_user_path(@user), notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    # Careful when using update_without_password!!
    # Only admins should have this capability
    if @user.update_without_password(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def show
    sims_page = params[:sims_page] || 1
    @sims = @user.sims.page(sims_page).per(5)
    trips_page = params[:trips_page] || 1
    @trips = @user.trips.page(trips_page).per(5)
    auth_tokens_page = params[:auth_tokens_page] || 1
    @auth_tokens = @user.auth_tokens.page(auth_tokens_page).per(5)
    @data_plan = @user.data_plan
    data_usage_records_page = params[:data_usage_records_page] || 1
    @data_usage_records = @user.data_usage_records.page(data_usage_records_page).order(start: :desc).per(5)
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: 'User was successfully removed.'
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    params.fetch(:user, {}).permit(
      :first_name,
      :last_name,
      :email,
      :password,
      :beta_user,
    )
  end
end
