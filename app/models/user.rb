class User < ApplicationRecord
  validates :name, uniqueness: true
  validates :name, presence: true

  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { minimum: 6 },
                       :unless => :already_has_password?
  has_secure_password

  has_many :recipes
  has_many :ingredients, through: :recipes
  has_many :comments


  def self.find_or_create_from_omniauth(auth_hash)
    user = self.find_by(uid: auth_hash['info']['uid'], provider: auth_hash['provider'])
      if !user.nil?
        return user
      else
        user = User.new
        user.provider = auth_hash.provider
        user.uid = auth_hash.uid
        user.name = auth_hash.name
        user.first_name = auth_hash.first_name
        user.password = SecureRandom.urlsafe_base64
        user.oauth_token = auth_hash.credentials.token
        user.oauth_expires_at = Time.at(auth_hash.credentials.expires_at)
        user.save!

       if user.save
         return user
       else
         return nil
       end
     end
   end

   def already_has_password?
     !self.password_digest.blank?
   end
end
