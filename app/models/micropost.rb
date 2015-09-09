class Micropost < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order(created_at: :desc) } # Most recent first

  # Tell CarrierWave to associate the uploader with the Micropost.picture attribute
  mount_uploader :picture, PictureUploader
  
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate  :picture_size # use validate to call a custom validation (as opposed to validates)
  
  private
  
  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, "should be less than 5Mb")
    end
  end
end
