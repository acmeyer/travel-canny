class Admin::DataPlansController < Admin::ApplicationController
  load_and_authorize_resource
  before_action :find_user
  before_action :find_data_plan, only: [:edit, :update, :show, :destroy]

  def new
    @data_plan = @user.data_plans.build
  end

  def create
    @data_plan = @user.data_plans.build(data_plan_params)
    if @data_plan.save
      redirect_to admin_user_path(@user), notice: 'Data plan was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @data_plan.update(data_plan_params)
      redirect_to admin_user_path(@user), notice: 'Data plan was successfully updated.'
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    @data_plan.destroy
    redirect_to admin_user_path(@user), notice: 'Data plan was successfully removed.'
  end

  private
  def find_user
    @user = User.find(params[:user_id]) unless params[:user_id].blank?
  end

  def find_data_plan
    @data_plan = DataPlan.find(params[:id])
  end

  def data_plan_params
    params.fetch(:data_plan, {}).permit(
      :status,
      :total_amount,
      :total_amount_used,
      :warning_amount,
    )
  end
end
