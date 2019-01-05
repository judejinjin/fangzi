class Profile < ActiveRecord::Base
  validates :user, presence: true

  has_attached_file :photo, :styles => {
          :big => "574x385#",
          :small => "180x113#"
          }, :default_url => "/images/missing_:style.png"

  validates_attachment_content_type(
          :photo,
          :content_type => /\Aimage\/.*\Z/
        )

  belongs_to(
    :user,
    class_name: "User",
    foreign_key: :user_id,
    primary_key: :id,
    inverse_of: :user_profile
  )

end
