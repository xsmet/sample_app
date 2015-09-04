module SessionsHelper
  
  # Logs in the given user
  # Automagically creates encrypted temporary cookie, which is
  # safe because it's temporary (no session hijacking possible)
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # Returns the current logged-in user (if any)
  # Uses ||=, which is equal to "if it's nil, assign":
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  
  # Returns true if a user is logged in, false otherwise
  def logged_in?
    !current_user.nil?
  end
  
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
    
end
