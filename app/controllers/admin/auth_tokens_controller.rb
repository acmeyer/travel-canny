class Admin::AuthTokensController < Admin::ApplicationController
  load_and_authorize_resource
  before_action :find_user
  before_action :find_auth_token, only: [:show, :destroy, :expire]

  def show
  end

  def destroy
    @auth_token.destroy
    redirect_to admin_user_path(@user), notice: 'Token was successfully removed.'
  end

  def expire
    @auth_token.expires_at = DateTime.now
    @auth_token.save
    redirect_to admin_user_path(@user), notice: 'Token was successfully expired.'
  end

  private
  def find_user
    @user = User.find(params[:user_id]) unless params[:user_id].blank?
  end

  def find_auth_token
    @auth_token = AuthToken.find(params[:id])
  end
end
