class UserMailer < ApplicationMailer

  def welcome_email(user_id)
    @user = User.find(user_id)
    mail(to: @user.email, from: 'hi@example.com', subject: 'Welcome to Travel Canny!')
  end
end
