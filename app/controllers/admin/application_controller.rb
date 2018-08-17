module Admin
  class ApplicationController < ActionController::Base
    layout 'admin'
    before_action :authenticate_admin

    private
    def authenticate_admin
      redirect_to new_user_session_path, :alert => "Login required." unless current_user && current_user.admin?
    end
  end
end
