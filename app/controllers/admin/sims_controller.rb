class Admin::SimsController < Admin::ApplicationController
  load_and_authorize_resource
  before_action :find_sim, only: [:edit, :update, :show, :destroy]

  def index
    page = params[:page] || 1
    if params[:search_query].blank?
      @sims = Sim.all.order(:id).page(page).per(20)
    else
      @search_query = params[:search_query]
      @sims = Sim.search_sims(@search_query).order(:id).page(page).per(20)
    end
  end

  def new
    @sim = Sim.new(user_id: params[:user_id])
  end

  def create
    begin
      @sim = Sim.new(sim_params)
      @sim.save!
      redirect_to admin_sim_path(@sim), notice: 'SIM was successfully created.'
    rescue => e
      flash.now[:error] = "#{e.message}"
      render :new
    end
  end

  def edit
  end

  def update
    if @sim.update(sim_params)
      redirect_to admin_sim_path(@sim), notice: 'SIM was successfully updated.'
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    @sim.destroy
    redirect_to admin_sims_path, notice: 'SIM was successfully removed.'
  end

  private

  def find_sim
    @sim = Sim.find(params[:id])
  end

  def sim_params
    params.fetch(:sim, {}).permit(
      :sid,
      :uuid,
      :activation_code,
      :rate_plan_sid,
      :name,
      :status,
      :iccid,
      :phone_number,
      :country_code,
      :user_id,
      :test_sim,
    )
  end
end
