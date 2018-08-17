class Admin::CountriesController < Admin::ApplicationController
  load_and_authorize_resource
  before_action :find_country, only: [:edit, :update, :show, :destroy]

  def index
    page = params[:page] || 1
    if params[:search_query].blank?
      @countries = Country.all.order(:id).page(page).per(20)
    else
      @search_query = params[:search_query]
      @countries = Country.search_countries(@search_query).order(:id).page(page).per(20)
    end
  end

  def new
    @country = Country.new
  end

  def create
    @country = Country.new(country_params)
    if @country.save
      redirect_to admin_country_path(@country), notice: 'Country was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @country.update(country_params)
      redirect_to admin_country_path(@country), notice: 'Country was successfully updated.'
    else
      render :edit
    end
  end

  def show
  end

  def destroy
    @country.destroy
    redirect_to admin_countries_path, notice: 'Country was successfully removed.'
  end

  private

  def find_country
    @country = Country.find(params[:id])
  end

  def country_params
    params.fetch(:country, {}).permit(
      :name,
      :country_code,
      :emergency_phone_numbers,
      :underrated,
      :overrated,
      :fun_facts,
    )
  end
end
