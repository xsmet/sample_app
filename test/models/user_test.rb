require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                      password: "foobar", password_confirmation: "foobar")
  end
  
  test "should be valid" do
    assert @user.valid?
  end
  
  test "name should be present" do
    @user.name = "    "
    assert_not @user.valid?
  end
  
  test "email should be present" do
    @user.email = "    "
    assert_not @user.valid?
  end
  
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com ALLCAPS@MaIL.org A_Undersc@ore.be 
                        with.dots@more.dots.jp xavier+mycomment@gmail.com]
                        
    valid_addresses.each do |s|
      @user.email = s
      assert @user.valid?, "#{s.inspect} should be valid"
    end
  end
  
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[no@tld,com no_at_sign.com no@tld.
                          underscore@in_domain.com plus@in_domain.com
                          double@dots..com ]
    invalid_addresses.each do |s|
      @user.email = s
      assert_not @user.valid?, "#{s.inspect} should be invalid"
    end
  end
  
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    assert @user.save # First user can be added to the database
    assert_not duplicate_user.valid? # Second one is no longer valid
  end
  
  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end
  
  test "password should be nonblank and have a minimum length" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
    
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  
  test "associated microposts should be destroyed with the user" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      # When we destroy a user with exactly one micropost,
      # the post should also be destroyed (count -1)
      @user.destroy
    end
  end
  
  test "should follow and unfollow a user" do
    xavier = users(:xavier)
    archer  = users(:archer)
    assert_not xavier.following?(archer)
    xavier.follow(archer)
    assert xavier.following?(archer)
    assert archer.followers.include?(xavier)
    xavier.unfollow(archer)
    assert_not xavier.following?(archer)
  end
  
  test "feed should have the right posts" do
    xavier = users(:xavier)
    archer  = users(:archer)
    lana    = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert xavier.feed.include?(post_following)
    end
    # Posts from self
    xavier.microposts.each do |post_self|
      assert xavier.feed.include?(post_self)
    end
    # Posts from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not xavier.feed.include?(post_unfollowed)
    end
  end

end
