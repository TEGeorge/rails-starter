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
    # Using a private method to encapsulate the permitted parameters is a good
    # pattern. You can use the same list for both create and update.
    def user_params
      params.require(:user).permit(:email_address, :password, :password_confirmation)
    end
end

# def create
#   @user = User.new(user_params)
#
#   if @user.save
#     redirect_to @user, notice: "User created successfully"
#   else
#     render :new, status: :unprocessable_entity
#   end
# end
#
# private
#
# def user_params
#   params.require(:user).permit(:email, :password, :password_confirmation)
# end
