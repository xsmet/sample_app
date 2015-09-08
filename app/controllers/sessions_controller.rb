class SessionsController < ApplicationController
  def new
  end
  
  def create
    # Use instance variable @user instead of plain local variable 'user'
    # because that's testable with assigns(:user) in test/integration/users_login_test.rb
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        log_in @user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        redirect_back_or(@user)
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination' # Not quite right!
      render 'new'
    end
  end
  
  def destroy
    log_out if logged_in? # User could have logged out in a different tab already
    redirect_to root_url
  end
end
