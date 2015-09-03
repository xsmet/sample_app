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
                          underscore@in_domain.com plus@in_domain.com]
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
  
  test "password should be nonblank and have a minimum length" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
    
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
end
