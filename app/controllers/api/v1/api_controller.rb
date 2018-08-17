class Api::V1::ApiController < ApplicationController
  include ApiHelper
  attr_accessor :current_user
  skip_before_action :verify_authenticity_token

  before_action :verify_client_key
  before_action :get_ip_address, :get_user_agent
  before_action :authenticate_user_from_token!, :set_current_user

  # Custom Error classes for raising 4XX responses
  class Api::V1::Forbidden < StandardError
  end
  class Api::V1::NotFound < StandardError
  end
  class Api::V1::Invalid < StandardError
  end
  class Api::V1::Unauthorized < StandardError
  end  

  rescue_from ActionController::RoutingError, with: :record_not_found
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from Api::V1::Forbidden, with: :forbidden
  rescue_from Api::V1::NotFound, with: :record_not_found
  rescue_from Api::V1::Invalid, with: :record_invalid
  rescue_from Api::V1::Unauthorized, with: :unauthorized
  rescue_from CanCan::AccessDenied, with: :forbidden

  protected
  def record_not_found(e)
    msg = /Couldn't find (.*) with 'id'=(.*)/.match(e.message)
    render json: { error: msg.nil? ? e.message : "#{msg[1]} #{msg[2]} not found" }, status: 404
  end

  def record_invalid(e)
    render json: { error: e.message, validation_errors: e.try(:record).try(:errors) }, status: 422
  end

  def forbidden(e)
    render json: { error: "Action forbidden." }, status: 403
  end

  def authenticate_user_from_token!
    begin
      token = request.headers['Authorization']
      user_email = request.headers['User-Email']
      user = user_email && User.find_by_email(user_email)
      auth_token = user.auth_tokens.not_expired.where(token: token).first

      if user && Devise.secure_compare(auth_token.try(:token), token)
        auth_token.update_last_used(@ip_address, @user_agent)
      else
        raise Api::V1::Unauthorized unless !auth_token.blank?
      end
    rescue => e
      STDERR.puts("API authorization failed: #{e}")
      render json: {error: 'Unauthorized'}, status: 401
    end
  end

  def set_current_user
    token = request.headers['Authorization']
    valid_token = AuthToken.not_expired.where(token: token).first
    self.current_user = valid_token.user
  end

  def get_ip_address
    @ip_address = request.remote_ip
  end

  def get_user_agent
    @user_agent = request.user_agent
  end
end