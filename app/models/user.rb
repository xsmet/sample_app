class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  
  # Following
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed

  # Followers
  has_many :passive_relationships,class_name:  "Relationship",
                                  foreign_key: "followed_id",
                                  dependent:   :destroy
  has_many :followers, through: :passive_relationships, source: :follower
  
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest
  
  validates :name, presence: true, length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX},
                    uniqueness: { case_sensitive: false }

  has_secure_password
  
  # Password can be nil here, e.g. when updating a user (and not providing a new password)
  validates :password, presence:true, length: { minimum: 6 }, allow_nil: true
  
  # Remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # Returns true if the given token matches the digest
  # - an empty remember_token also returns false
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  # Forget a persisted user's remember_digest
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns( reset_digest:  User.digest(reset_token),
                    reset_sent_at: Time.zone.now)
  end
  
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  def feed
    # 1. Original
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    
    # 2. Equivalent, but rewritten 
    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id", 
    #                        following_ids: following_ids, user_id: id)
    
    # 3. Equivalent result, but we build a more efficient query                       
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
                     
    # 4. Of course, even the subselect won’t scale forever. 
    #    For bigger sites, you would probably 
    #    need to generate the feed asynchronously using a background job
  end
  
  # Follows a user
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end
  
  # Unfollows a user
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end
  
  # Returns true if the current user is following the other_user
  def following?(other_user)
    following.include?(other_user)
  end
  
  # Methods that don't require an instance of this class (alternative: define User.digest()
  class << self
    # Returns hash digest of a string
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : 
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
    
    # Returns a random token
    def new_token
      SecureRandom.urlsafe_base64
    end
  end
  
  private
    def downcase_email
      email.downcase! # Bang! method, equivalent to: self.email=email.downcase
    end
    
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
