require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  # 1. Visit the login path.
  # 2. Verify that the new sessions form renders properly.
  # 3. Post to the sessions path with an invalid params hash.
  # 4. Verify that the new sessions form gets re-rendered and that a flash message appears.
  # 5. Visit another page (such as the Home page).
  # 6. Verify that the flash message doesn’t appear on the new page.
  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: { email: "", password: "" }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
  
  def setup
    @user = users(:tom)
  end
  
  # 1. Go to login page
  # 2. Create a new session for this user/password (password digest defined in fixture)
  # 3. Verify we'll be redirected to the right page (profile page for this user)
  # 4. ...and follow it
  # 5. Verify this is the correct template (a users/show page)
  # 6. Also make sure there's no links anymore to the login page (count: 0)
  # 7. Verify we have a logout link, and a link to the profile page (which happens to also be the current page)
  test "login with valid information followed by logout" do
    get login_path
    post login_path, session: { email: @user.email, password: 'password' }
    assert_redirected_to @user
    follow_redirect!
    assert_not flash.key?('danger')   # No errors,
    assert_not flash.key?('info')     # No notifications, 
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    
    delete logout_path # Call 'destroy' action in a RESTful way
    assert_not is_logged_in?
    assert_redirected_to root_url

    # Simulate a user clicking logout in a second window.
    delete logout_path

    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,       count: 0
    assert_select "a[href=?]", user_path(@user),  count: 0
  end

  # Old test commented out, the new test uses 'assigns(:user)'
  # to access the @user instance variable in the controller (sessions_helper.rb#current_user)
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    # assert_not_nil cookies['remember_token']
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end
  
  test "login without remembering" do
    log_in_as(@user, remember_me: '0')
    assert_nil cookies['remember_token']
  end
end
