class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url, notice: "User created successfully"
    else
      redirect_to signup_path, alert: "Failed to create user"
    end
  rescue
      redirect_to signup_path, alert: "Failed to create user"
  end
  private
    def user_params
      params.require(:user).permit(:email_address, :password, :password_confirmation)
    end
end
