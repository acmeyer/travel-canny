class Api::V1::UsersController < Api::V1::ApiController
  authorize_resource

  def me
    Rails.logger.debug "user: #{current_user}"
    @user = current_user
    render_user
  end

  def change_password
    @user = current_user
    # TODO
  end

  private
  def render_user
    json = UserJson.new(@user, :full).call
    render json: json.as_json
  end
end