class Api::V1::AuthController < ApplicationController
  include ApiHelper
  skip_before_action :verify_authenticity_token

  before_action :verify_client_key
  before_action :get_ip_address, :get_user_agent

  class Api::V1::Unauthorized < StandardError
  end

  rescue_from ActionController::RoutingError, with: :not_found
  rescue_from Api::V1::Unauthorized, with: :unauthorized
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  def sign_in
    begin
      @user = User.find_for_authentication(:email => params[:email])
      if @user&.valid_password?(params[:password])
        AuthToken.generate_new_token(@user.id, @ip_address, @user_agent)
        @user.reload
        render_user
      else
        render_error_message(t('api.auth.invalid_email_or_password'))
      end
    rescue => e
      render_error_message(e.message)
    end
  end

  def sign_up
    begin
      # First, sign user up
      @user = User.new(user_sign_up_params)
      @user.save!
      AuthToken.generate_new_token(@user.id, @ip_address, @user_agent)
      @user.reload

      # Next, add their payment information
      if params[:billing_same_as_shipping]
        shipping_address = @user.shipping_address
        billing_address = {
          street_1: shipping_address.street_1,
          street_2: shipping_address.street_2,
          city: shipping_address.city,
          state: shipping_address.state,
          postal_code: shipping_address.postal_code,
          country: shipping_address.country
        }
      else
        billing_address = {
          street_1: params[:billing_street_1],
          street_2: params[:billing_street_2],
          city: params[:billing_city],
          state: params[:billing_state],
          postal_code: params[:billing_postal_code],
          country: params[:billing_country]
        }
      end
      @user.add_payment_source(params[:stripe_token], billing_address)

      # Then, add their trip details
      if !params[:trip_countries].blank?
        trip_countries = params[:trip_countries]
        @user.add_trip(trip_countries)
      end

      # Finally, return the user if successful
      render_user
    rescue => e
      # TODO: possibly handle errors better here since the user could save but something else fail
      record_invalid(e)
    end
  end

  private
  def render_user
    json = UserJson.new(@user, :full).call
    render json: json.as_json
  end

  def render_error_message(message)
    render json: {error: message}, status: 422
  end

  def record_invalid(e)
    render json: { error: e.message, validation_errors: e.try(:record).try(:errors) }, status: 422
  end

  def get_ip_address
    @ip_address = request.remote_ip
  end

  def get_user_agent
    @user_agent = request.user_agent
  end

  def user_sign_up_params
    params.fetch(:user, {}).permit(
      :first_name,
      :last_name,
      :email,
      :password,
      :password_confirmation,
      shipping_address_attributes: [:street_1, :street_2, :city, :state, :country, :postal_code],
    )
  end
end