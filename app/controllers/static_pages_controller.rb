class StaticPagesController < ApplicationController
  def home
    # @micropost won't be defined on the homepage if nobody is logged in
    @micropost = current_user.microposts.build if logged_in?
  end

  def help
  end
  
  def about
  end
  
  def contact
  end
end
